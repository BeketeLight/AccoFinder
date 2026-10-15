import QtQuick 2.15

Row {
    id: root
    property int value: 0        // 1..5
    property int starSize: 32
    signal valueEdited(int newValue)

    spacing: 6

    Repeater {
        model: 5
        delegate: Item {
            width: root.starSize
            height: root.starSize

            Text {
                anchors.centerIn: parent
                text: "\u2605"
                font.pixelSize: root.starSize
                color: (index + 1) <= root.value ? "#FFC107" : "#BDBDBD"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.value = index + 1;
                    root.valueEdited(root.value);
                }
            }
        }
    }
}
