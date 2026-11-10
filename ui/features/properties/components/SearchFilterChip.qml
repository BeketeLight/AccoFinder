import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string label: ""
    property string valueText: ""
    property bool active: false

    signal clicked

    implicitHeight: 34
    implicitWidth: chipLabel.implicitWidth + 24
    radius: 17
    color: active ? "#2563EB" : "#F5F5F5"
    border.color: active ? "transparent" : "#E5E7EB"
    border.width: active ? 0 : 1
    opacity: root.enabled ? 1.0 : 0.45

    Label {
        id: chipLabel
        anchors.centerIn: parent
        text: root.active && root.valueText.length > 0 ? root.label + ": " + root.valueText : root.label
        font.pixelSize: 13
        font.weight: root.active ? Font.DemiBold : Font.Normal
        color: root.active ? "#FFFFFF" : "#1F2937"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
