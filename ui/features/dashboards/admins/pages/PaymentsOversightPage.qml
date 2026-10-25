import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../models"
import "../../../../utils/Utils.js" as Utils
import "../delegates"
import "../../../../components/inputs"

Item {
    id: root

    property AdminPaymentsModel paymentsModel: AdminPaymentsModel {}
    property string pageTitle: qsTr("Payments")

    signal paymentAction(var action, var reference)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color mutedColor: "#6B7280"

    property string activeTab: "PAYMENTS"   // PAYMENTS | COMMISSIONS | PAYOUTS

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            StatCard {
                lableFontSize: 18
                Layout.fillWidth: true
                label: qsTr("Collected")
                valueText: Utils.formatCurrency(root.paymentsModel.totalCollected)
                accentColor: root.successColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Pending payments")
                valueText: String(root.paymentsModel.pendingCount)
                accentColor: root.warningColor
            }
            StatCard {
                lableFontSize: 18
                Layout.fillWidth: true
                label: qsTr("Commissions due")
                valueText: Utils.formatCurrency(root.paymentsModel.commissionsDue)
                accentColor: root.primaryColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Payouts pending")
                valueText: String(root.paymentsModel.payoutsPending)
                accentColor: root.dangerColor
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { key: "PAYMENTS", label: qsTr("Payments") },
                    { key: "COMMISSIONS", label: qsTr("Commissions") },
                    { key: "PAYOUTS", label: qsTr("Payouts") }
                ]

                delegate: Button {
                    required property var model
                    readonly property bool isCurrent: root.activeTab === model.key
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    padding: 0

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: model.label
                        color: parent.isCurrent ? "#FFFFFF" : "#374151"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 16
                        color: parent.isCurrent ? root.primaryColor : "#FFFFFF"
                        border.color: parent.isCurrent ? root.primaryColor : "#E5E7EB"
                    }

                    onClicked: root.activeTab = model.key
                }
            }
        }

        // ---- Payments tab ----
        ColumnLayout {
            id: paymentsTabCol
            visible: root.activeTab === "PAYMENTS"
            Layout.fillWidth: true
            spacing: 10

            property string paymentsStatusFilter: "ALL"
            property string paymentsSearchText: ""

            AppSearchBar {
                Layout.fillWidth: true
                placeholder: qsTr("Search name, transaction ref, or booking ID")
                backgroundColor: "#FFFFFF"
                focusColor: "#2563EB"
                fieldHeight: 48
                text: paymentsTabCol.paymentsSearchText
                onTextEdited: {
                    paymentsTabCol.paymentsSearchText = text
                }
                onCleared: {
                    paymentsTabCol.paymentsSearchText = ""
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { key: "ALL", label: qsTr("All") },
                        { key: "Initiated", label: qsTr("Initiated") },
                        { key: "Failed", label: qsTr("Failed") },
                        { key: "Success", label: qsTr("Succeeded") }
                    ]

                    delegate: Button {
                        id: payFilterBtn
                        required property var model
                        readonly property bool isCurrent: paymentsTabCol.paymentsStatusFilter === model.key
                        Layout.preferredHeight: 32
                        padding: 0

                        contentItem: Label {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: payFilterBtn.model.label
                            color: payFilterBtn.isCurrent ? "#FFFFFF" : "#374151"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        background: Rectangle {
                            radius: 16
                            color: payFilterBtn.isCurrent ? root.primaryColor : "#FFFFFF"
                            border.color: payFilterBtn.isCurrent ? root.primaryColor : "#E5E7EB"
                            border.width: 1
                        }

                        onClicked: {
                            paymentsTabCol.paymentsStatusFilter = payFilterBtn.model.key
                        }
                    }
                }
            }

            Repeater {
                model: root.paymentsModel.paymentsModel

                delegate: PaymentRowDelegate {
                    visible: {
                        var col = paymentsTabCol
                        if (!col || col.visible === false) return false
                        if (col.paymentsStatusFilter && col.paymentsStatusFilter !== "ALL") {
                            var s = String(model.status || "")
                            if (col.paymentsStatusFilter === "Succeeded") {
                                if (!(s === "Success" || s === "Completed" || s === "Paid" || s === "Settled")) return false
                            } else {
                                if (s !== col.paymentsStatusFilter) return false
                            }
                        }
                        var q = String(col.paymentsSearchText || "").toLowerCase()
                        if (q.length > 0) {
                            var u = String(model.user || "").toLowerCase()
                            var tr = String(model.transactionRef || "").toLowerCase()
                            var bid = String(model.booking || model.bookingId || "").toLowerCase()
                            var pid = String(model.paymentId || "").toLowerCase()
                            if (u.indexOf(q) === -1 && tr.indexOf(q) === -1 && bid.indexOf(q) === -1 && pid.indexOf(q) === -1) return false
                        }
                        return true
                    }
                    paymentId: model.paymentId
                    amount: model.amount
                    status: model.status
                    user: model.user
                    kind: model.kind
                    method: model.method
                    date: model.date
                    bookingId: model.booking || model.bookingId || ""
                    transactionRef: model.transactionRef || ""
                    onActionRequested: (paymentId, kind) => {
                        if (kind === "settled") {
                            root.paymentsModel.setPaymentStatus(paymentId, "Completed")
                            console.log("Payment settled:", paymentId)
                            root.paymentAction("settled", paymentId)
                        } else if (kind === "cancel") {
                            console.log("Payment cancellation requested:", paymentId)
                            root.paymentAction("cancel", paymentId)
                        } else {
                            console.log("Payment flagged for review:", paymentId)
                            root.paymentAction("flagged", paymentId)
                        }
                    }
                }
            }

            Label {
                visible: {
                    var m = root.paymentsModel.paymentsModel
                    var total = 0
                    if (!m) total = 0
                    else if (typeof m.count === "function") total = m.count()
                    else if (typeof m.rowCount === "function") total = m.rowCount()
                    else if (typeof m.count === "number") total = m.count
                    if (total === 0) return true
                    var shown = 0
                    for (var i = 0; i < total; i++) {
                        var it = m.get ? m.get(i) : (m.at ? m.at(i) : null)
                        if (!it) continue
                        if (paymentsTabCol.paymentsStatusFilter && paymentsTabCol.paymentsStatusFilter !== "ALL") {
                            var s = String(it.status || "")
                            if (paymentsTabCol.paymentsStatusFilter === "Succeeded") {
                                if (!(s === "Success" || s === "Completed" || s === "Paid" || s === "Settled")) continue
                            } else {
                                if (s !== paymentsTabCol.paymentsStatusFilter) continue
                            }
                        }
                        var q = String(paymentsTabCol.paymentsSearchText || "").toLowerCase()
                        if (q.length > 0) {
                            var u = String(it.user || "").toLowerCase()
                            var tr = String(it.transactionRef || "").toLowerCase()
                            var bid = String(it.booking || it.bookingId || "").toLowerCase()
                            var pid = String(it.paymentId || "").toLowerCase()
                            if (u.indexOf(q) === -1 && tr.indexOf(q) === -1 && bid.indexOf(q) === -1 && pid.indexOf(q) === -1) continue
                        }
                        shown++
                    }
                    return shown === 0
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: (paymentsTabCol.paymentsSearchText && paymentsTabCol.paymentsSearchText.length > 0) || (paymentsTabCol.paymentsStatusFilter && paymentsTabCol.paymentsStatusFilter !== "ALL")
                      ? qsTr("No payments match your filters.")
                      : qsTr("No payments to show.")
                color: root.mutedColor
                font.pixelSize: 12
                topPadding: 8
            }
        }

        // ---- Commissions tab ----
        ColumnLayout {
            visible: root.activeTab === "COMMISSIONS"
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.paymentsModel.commissionsModel

                delegate: CommissionRowDelegate {
                    agent: model.agent
                    amount: model.amount
                    status: model.status
                    bookings: model.bookings
                    area: model.area
                    rate: model.rate
                    onSettleRequested: (agent) => {
                        root.paymentsModel.setCommissionStatus(agent, "Settled")
                        console.log("Commission settled:", agent)
                        root.paymentAction("commission-settled", agent)
                    }
                }
            }

            Label {
                visible: (function() {
                    var m = root.paymentsModel.commissionsModel
                    if (!m) return true
                    if (typeof m.count === "function") return m.count() === 0
                    if (typeof m.rowCount === "function") return m.rowCount() === 0
                    if (typeof m.count === "number") return m.count === 0
                    return true
                })()
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("No commissions due yet.")
                color: root.mutedColor
                font.pixelSize: 12
                topPadding: 8
            }
        }

        // ---- Payouts tab ----
        ColumnLayout {
            visible: root.activeTab === "PAYOUTS"
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.paymentsModel.payoutsModel

                delegate: PayoutRowDelegate {
                    landlord: model.landlord
                    amount: model.amount
                    status: model.status
                    propertyName: model.property
                    period: model.period
                    onReleaseRequested: (landlord) => {
                        root.paymentsModel.setPayoutStatus(landlord, "Paid")
                        console.log("Payout released:", landlord)
                        root.paymentAction("payout-released", landlord)
                    }
                }
            }

            Label {
                visible: (function() {
                    var m = root.paymentsModel.payoutsModel
                    if (!m) return true
                    if (typeof m.count === "function") return m.count() === 0
                    if (typeof m.rowCount === "function") return m.rowCount() === 0
                    if (typeof m.count === "number") return m.count === 0
                    return true
                })()
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("No payouts scheduled yet.")
                color: root.mutedColor
                font.pixelSize: 12
                topPadding: 8
            }
        }
    }
}
