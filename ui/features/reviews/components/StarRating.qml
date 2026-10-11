import QtQuick 2.15

Row {
    id: root
    property real value: 0        // 0..5
    property int starSize: 18
    property color filledColor: "#FFC107"
    property color emptyColor: "#BDBDBD"

    spacing: 2

    Repeater {
        model: 5
        delegate: Text {
            text: "\u2605"                 // ★
            font.pixelSize: root.starSize
            color: (index + 1) <= Math.round(root.value) ? root.filledColor : root.emptyColor
        }
    }
}
