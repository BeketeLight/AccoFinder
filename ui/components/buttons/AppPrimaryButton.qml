import QtQuick 2.15
import QtQuick.Controls

Button {
    id: root

    // ---- Public API ----
    property color customBackgroundColor: "#2563EB"
    property color customTextColor: "#FFFFFF"
    property real customRadius: 8
    property string customText: qsTr("change me")
    property color customBorderColor: "transparent"
    property int customBorderWidth: 0

    text: root.customText

    contentItem: Text {
        text: root.text
        font: root.font
        color: root.customTextColor
        opacity: root.enabled ? 1.0 : 0.4
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        radius: root.customRadius
        color: root.customBackgroundColor
        opacity: root.enabled ? 1.0 : 0.4
        border.color: root.customBorderColor
        border.width: root.customBorderWidth
    }
}
