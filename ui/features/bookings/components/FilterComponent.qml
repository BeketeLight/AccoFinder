import QtQuick
import QtQuick.Controls

TabButton {
    id: root

    // Optional theme hooks
    property color activeColor: "#2563EB"
    property color inactiveTextColor: "#64748B"
    property color inactiveBorderColor: "#E2E8F0"

    width: implicitWidth
    height: 36
    leftPadding: 16
    rightPadding: 16

    contentItem: Text {
        text: root.text
        font.pixelSize: 13
        font.bold: root.checked
        color: root.checked ? "#FFFFFF" : root.inactiveTextColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitHeight: 36
        radius: 18
        color: root.checked ? root.activeColor : "transparent"
        border.width: root.checked ? 0 : 1
        border.color: root.inactiveBorderColor
    }
}