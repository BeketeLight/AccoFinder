import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../components/pages"
import "../../../../components/buttons"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Payments Oversight")
    property bool showHeader: true
    property bool showBack: true

    property string _cancelPaymentId: ""
    property string _cancelBookingId: ""
    property string _cancelTxRef: ""
    property real _cancelAmount: 0
    property string _cancelMethod: ""
    property string _cancelStatus: ""
    property bool _cancelInProgress: false
    property string _cancelError: ""

    function goBack() { NavUtils.pop() }

    signal paymentAction(var action, var reference)

    function refresh() {
        PaymentsOverviewViewModel.refresh()
    }

    Connections {
        target: (typeof PaymentController !== "undefined") ? PaymentController : null
        ignoreUnknownSignals: true
        function onPaymentCancelled(payment) {
            root.finishCancel(true, "")
        }
        function onPaymentRefunded(payment) {
            root.finishCancel(true, "")
        }
        function onPaymentError(err) {
            root.finishCancel(false, err || qsTr("Failed to cancel payment"))
        }
    }

    function finishCancel(success, message) {
        root._cancelInProgress = false
        if (success) {
            root._cancelError = ""
            console.log("[PaymentsOversight] payment cancelled successfully")
            PaymentsOverviewViewModel.refresh()
            cancelDialog.close()
        } else {
            // Keep the dialog open so the admin can read the reason and retry.
            root._cancelError = message
            console.warn("[PaymentsOversight] payment cancel failed:", message)
        }
    }

    function performCancelPayment() {
        if (_cancelInProgress) return
        if (root._cancelPaymentId === "" && root._cancelBookingId === "" && root._cancelTxRef === "") {
            root._cancelError = qsTr("Missing payment details")
            return
        }
        root._cancelError = ""
        _cancelInProgress = true
        if (typeof PaymentController !== "undefined" && PaymentController.cancelPayment) {
            PaymentController.cancelPayment(root._cancelPaymentId, root._cancelBookingId, root._cancelAmount, root._cancelMethod, root._cancelStatus, root._cancelTxRef)
            return
        }
        root.finishCancel(false, qsTr("Payment cancellation unavailable"))
    }

    AppScrollablePage {
        anchors.fill: parent
        loading: PaymentsOverviewViewModel.isLoading

        PaymentsOversightPage {
            id: paymentsPage
            Layout.fillWidth: true

            onPaymentAction: (action, reference) => {
                if (action === "cancel") {
                    var pModel = paymentsPage.paymentsModel ? paymentsPage.paymentsModel.paymentsModel : null
                    var count = 0
                    if (pModel) {
                        if (typeof pModel.count === "function") count = pModel.count()
                        else if (typeof pModel.rowCount === "function") count = pModel.rowCount()
                        else if (typeof pModel.count === "number") count = pModel.count
                    }
                    for (var i = 0; i < count; i++) {
                        var row = null
                        if (typeof pModel.get === "function") row = pModel.get(i)
                        else if (typeof pModel.at === "function") row = pModel.at(i)
                        if (!row) continue
                        if ((row.paymentId && row.paymentId === reference) || (row.id && row.id === reference)) {
                            root._cancelPaymentId = row.paymentId || row.id || ""
                            root._cancelBookingId = row.bookingId || row.booking || ""
                            root._cancelTxRef = row.transactionRef || row.transaction_ref || ""
                            root._cancelAmount = row.amount || 0
                            root._cancelMethod = row.method || ""
                            root._cancelStatus = row.status || ""
                            break
                        }
                    }
                    if (!root._cancelPaymentId && !root._cancelBookingId && !root._cancelTxRef) {
                        root._cancelPaymentId = reference
                    }
                    _cancelInProgress = false
                    root._cancelError = ""
                    cancelDialog.open()
                    return
                }
                root.paymentAction(action, reference)
            }
        }
    }

    Popup {
        id: cancelDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(root.width - 48, 340)
        padding: 20
        closePolicy: root._cancelInProgress ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)

        background: Rectangle {
            radius: 16
            color: "#FFFFFF"
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Cancel payment?")
                color: "#111827"
                font.pixelSize: 16
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("This payment will be marked as failed and the room will be released if not already confirmed. This action cannot be undone.")
                color: "#6B7280"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                visible: root._cancelError !== ""
                text: root._cancelError
                color: "#DC2626"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                Button {
                    id: keepButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    enabled: !root._cancelInProgress
                    text: qsTr("Keep")

                    contentItem: Label {
                        text: keepButton.text
                        color: "#111827"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: "transparent"
                        border.color: "#E5E7EB"
                        border.width: 1
                    }

                    onClicked: cancelDialog.close()
                }

                Button {
                    id: confirmCancelButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    enabled: !root._cancelInProgress
                    text: root._cancelInProgress ? "" : qsTr("Cancel payment")

                    contentItem: Item {
                        anchors.fill: parent

                        Label {
                            visible: !root._cancelInProgress
                            anchors.centerIn: parent
                            text: confirmCancelButton.text
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        BusyIndicator {
                            visible: root._cancelInProgress
                            anchors.centerIn: parent
                            running: root._cancelInProgress
                            width: 20
                            height: 20
                        }
                    }

                    background: Rectangle {
                        radius: 22
                        color: confirmCancelButton.down && !root._cancelInProgress ? "#B91C1C" : "#DC2626"
                        opacity: root._cancelInProgress ? 0.8 : 1.0
                    }

                    onClicked: root.performCancelPayment()
                }
            }
        }
    }

    Component.onCompleted: root.refresh()
}
