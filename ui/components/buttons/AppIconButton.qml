import QtQuick 2.15
import QtQuick.Controls

Item {
    id: root

    property alias customWidth: root.width
    property alias customeHeight: root.height
    property alias customRadius: buttomBackground.radius
    property alias customBorder: buttomBackground.border

    signal clicked

    Button {
        id: control

        highlighted: true

        background: Rectangle {
            id: buttomBackground
            implicitWidth: customWidth
            implicitHeight: customeHeight
            border.color: control.down ? "#17a81a" : "#21be2b"
            border.width: 1
            radius: 2

            Image {
                id: image
                source: "file"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
            }
        }

        onClicked: clicked()
    }
}
