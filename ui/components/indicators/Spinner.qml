import QtQuick
import QtQuick.Controls

Item {
    id: root

    // Public Properties

    property bool running: true
    property color color: "#2196F3"
    property int size: 48
    property real lineWidth: 4
    property int duration: 900
    property string text: ""
    property color textColor: "#444444"
    property int textSize: 14
    property int spacing: 12

    implicitWidth: Math.max(size, label.implicitWidth)
    implicitHeight: text ? size + spacing + label.implicitHeight : size

    // Spinner

    Item {
        id: spinner
        width: root.size
        height: root.size
        anchors.horizontalCenter: parent.horizontalCenter

        // Background ring
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: root.color
            border.width: root.lineWidth
            opacity: 0.2
        }

        // Spinning arc (using Canvas - modern & performant)
        Canvas {
            id: canvas
            anchors.fill: parent
            visible: root.running

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var centerX = width / 2;
                var centerY = height / 2;
                var radius = (Math.min(width, height) - root.lineWidth) / 2;

                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, -Math.PI / 2, Math.PI * 0.8);
                ctx.lineWidth = root.lineWidth;
                ctx.strokeStyle = root.color;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            // Continuous rotation
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: root.duration
                loops: Animation.Infinite
                running: root.running
            }
        }
    }
    // Optional Text

    Text {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: spinner.bottom
        anchors.topMargin: root.spacing
        text: root.text
        color: root.textColor
        font.pixelSize: root.textSize
        visible: root.text.length > 0
        horizontalAlignment: Text.AlignHCenter
    }
}
