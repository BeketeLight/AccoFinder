import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolButton {
    id: root

    property bool active: false

    background: Rectangle {
        color: "transparent"

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 3
            radius: 2
            color: root.active ? "#2196F3" : "transparent"
        }
    }
}