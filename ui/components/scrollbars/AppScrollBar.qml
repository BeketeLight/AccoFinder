import QtQuick
import QtQuick.Controls

// Slim, rounded, auto-hiding scroll indicator used app-wide in place of the
// default Material scrollbar. Pure UI: the associated Flickable still drives
// position/size through the regular ScrollBar bindings. The thumb uses the
// app primary color while shown.
ScrollBar {
    id: root

    width: 6
    policy: ScrollBar.AsNeeded
    hoverEnabled: true

    contentItem: Rectangle {
        implicitWidth: 8
        radius: 3
        color: root.pressed ? "#1D4ED8" : "#2563EB"
        opacity: root.pressed ? 1.0 : (root.hovered ? 0.9 : (root.active ? 0.55 : 0.0))

        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}