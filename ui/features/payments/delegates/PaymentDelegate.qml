import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string paymentId: ""
    property string bookingId: ""
    property real amount: 0
    property string method: ""
    property int status: 0
    property string transactionRef: ""
    property string payoutStatus: ""
    property var paidAt: null                      // <-- new

    signal tapped

    readonly property string statusLabel: {
        switch (root.status) {
        case 0:
            return "Processing";
        case 1:
            return "Pending";
        case 2:
            return "Paid";
        case 3:
            return "Failed";
        case 4:
            return "Refunded";
        default:
            return "Unknown";
        }
    }
    readonly property color statusColor: {
        switch (root.status) {
        case 0:
            return "#2563EB";
        case 1:
            return "#F59E0B";
        case 2:
            return "#22C55E";
        case 3:
            return "#EF4444";
        case 4:
            return "#6B7280";
        default:
            return "#6B7280";
        }
    }

    implicitHeight: row.implicitHeight + 24
    radius: 12
    color: "#F5F5F5"
    border.color: "#E5E7EB"
    border.width: 1

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 4
            Layout.fillHeight: true
            radius: 2
            color: root.statusColor
        }

        Rectangle {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 21
            color: "#FFFFFF"

            Label {
                anchors.centerIn: parent
                text: "MK"
                color: root.statusColor
                font.pixelSize: 12
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                Layout.fillWidth: true
                text: root.method.length > 0 ? root.method.toUpperCase() : qsTr("Payment")
                color: "#1F2937"
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                visible: root.bookingId.length > 0
                text: qsTr("Booking %1").arg(root.bookingId)
                color: "#6B7280"
                font.pixelSize: 11
                elide: Text.ElideMiddle
            }
        }

        ColumnLayout {
            spacing: 2

            Label {
                Layout.alignment: Qt.AlignRight
                text: "MK " + root.amount.toLocaleString(Qt.locale("en_MW"), 'f', 0)
                color: "#1F2937"
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                Layout.alignment: Qt.AlignRight
                radius: 10
                color: Qt.rgba(root.statusColor.r, root.statusColor.g, root.statusColor.b, 0.12)
                border.color: root.statusColor
                border.width: 1
                implicitWidth: statusLabelItem.implicitWidth + 16
                implicitHeight: 20

                Label {
                    id: statusLabelItem
                    anchors.centerIn: parent
                    text: root.statusLabel
                    color: root.statusColor
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.tapped()
    }
}
