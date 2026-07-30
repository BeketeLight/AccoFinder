import QtQuick 2.15
import QtQuick.Controls

Item {
    id: root

    property alias customWidth: root.width
    property alias customeHeight: root.height
    property color customBackgroundColor
    property alias customRadius: buttomBackground.radius
    property alias customText: control.text
    property alias customBorder: buttomBackground.border
    property color customTextColor: buttonTextAttributes.color

    signal clicked

    Button {
        id: control
        text: qsTr("change me")
        highlighted: true

        contentItem: Text {
            id: buttonTextAttributes
            text: control.text
            font: control.font
            opacity: enabled ? 1.0 : 0.3
            color: control.down ? "#17a81a" : "#21be2b"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            id: buttomBackground
            implicitWidth: customWidth
            implicitHeight: customeHeight
            color: customColor
            opacity: enabled ? 1 : 0.3
            border.color: control.down ? "#17a81a" : "#21be2b"
            border.width: 1
            radius: 2
        }

        onClicked: clicked()
    }
}
