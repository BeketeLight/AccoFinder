import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/indicators"
import "../delegates"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    // Injected by the screen that pushes this page
    property var paymentsListModel: null

    readonly property int paymentCount: paymentsListModel ? paymentsListModel.count : 0

    // Emitted when the user pulls to refresh, or when the screen wants to
    // trigger a reload. The screen wires this to PaymentController.
    signal refreshRequested

    header: ToolBar {
        background: Rectangle {
            color: "#FFFFFF"
        }
        contentHeight: 56
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            ToolButton {
                implicitWidth: 40
                implicitHeight: 40
                Image {
                    width: 24
                    height: 24
                    source: "qrc:/ui/assets/back.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                }
                onClicked: NavUtils.pop()
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Payments history")
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    background: Rectangle {
        color: "#FFFFFF"
    }

    // ---- List ----
    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        visible: root.paymentCount > 0
        model: root.paymentsListModel
        spacing: 10
        topMargin: 16
        leftMargin: 16
        rightMargin: 16
        bottomMargin: 24

        delegate: PaymentDelegate {
            width: listView.width - listView.leftMargin - listView.rightMargin
            paymentId: model.paymentId || ""
            bookingId: model.bookingId || ""
            amount: model.amount || 0
            method: model.method || ""
            status: model.status || 0
            transactionRef: model.transactionRef || ""
            payoutStatus: model.payoutStatus || ""
            paidAt: model.paidAt || null

            onTapped: {
                NavUtils.push(Qt.resolvedUrl("../screens/PaymentStatusScreen.qml"), {
                    paymentId: paymentId,
                    bookingId: bookingId,
                    amount: amount
                });
            }
        }

        // Tiny pull-to-refresh hint at the top of the list
        onContentYChanged: {
            if (listView.dragging && listView.contentY <= -60)
                pullArmed = true;
        }
        onDragEnded: {
            if (pullArmed) {
                pullArmed = false;
                root.refreshRequested();
                listView.returnToBounds();
            }
        }
        property bool pullArmed: false
    }

    // ---- Empty ----
    AppEmptyState {
        anchors.centerIn: parent
        visible: root.paymentCount === 0
        iconText: "₤"
        iconBgColor: "#EFF6FF"
        iconBorderColor: "#BFDBFE"
        iconColor: "#2563EB"
        title: qsTr("No payments yet")
        subtitle: qsTr("Your payment history will appear here once you make your first payment.")
        maxSubtitleWidth: root.width - 64
    }

    // Optional: nice spinner overlay while the controller is fetching
    BusyIndicator {
        anchors.centerIn: parent
        running: PaymentController.isLoading
        visible: running
    }
}
