import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../../utils/Utils.js" as Utils

Rectangle {
    id: root

    property string agent: ""
    property real amount: 0
    property string status: ""
    property string bookings: ""
    property string area: ""
    property string rate: ""
    property color mutedColor: "#6B7280"

    signal settleRequested(var agent)

    function statusVariant(status) {
        if (status === "Completed" || status === "Paid" || status === "Settled") return "success"
        if (status === "Pending" || status === "Due") return "warning"
        return "danger"
    }

    Layout.fillWidth: true
    implicitHeight: commContent.implicitHeight + 20
    radius: 12
    color: "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    ColumnLayout {
        id: commContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: root.agent + " · " + Utils.formatCurrency(root.amount)
                color: "#111827"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            StatusChip {
                textValue: root.status
                variant: root.statusVariant(root.status)
            }
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("%1 bookings in %2 · %3% rate").arg(root.bookings).arg(root.area).arg(root.rate)
            color: root.mutedColor
            font.pixelSize: 11
        }

        Button {
            id: settleButton
            visible: root.status === "Due"
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignRight
            text: qsTr("Settle now")

            contentItem: Label {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: settleButton.text
                color: "#166534"
                font.pixelSize: 10
                font.bold: true
            }

            background: Rectangle {
                radius: 14
                color: settleButton.down ? "#DCFCE7" : "#F0FDF4"
                border.color: "#BBF7D0"
                border.width: 1
            }

            onClicked: root.settleRequested(root.agent)
        }
    }
}