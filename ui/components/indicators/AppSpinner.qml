import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool running: true
    property color color: "#2563EB"
    property int size: 48
    property real lineWidth: 4
    property int duration: 800
    property string text: ""
    property color textColor: "#374151"
    property int textSize: 14
    property int spacing: 12

    implicitWidth: Math.max(size, label.implicitWidth)
    implicitHeight: text ? size + spacing + label.implicitHeight : size

    opacity: running ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Item {
        id: spinner
        width: root.size
        height: root.size
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: root.color
            border.width: root.lineWidth
            opacity: 0.12

            SequentialAnimation on opacity {
                running: root.running
                loops: Animation.Infinite
                NumberAnimation { to: 0.22; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.12; duration: 900; easing.type: Easing.InOutSine }
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            visible: root.running

            property real arcEnd: 0.75

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var centerX = width / 2;
                var centerY = height / 2;
                var radius = (Math.min(width, height) - root.lineWidth) / 2;

                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, -Math.PI / 2,
                        -Math.PI / 2 + Math.PI * 2 * canvas.arcEnd);
                ctx.lineWidth = root.lineWidth;
                ctx.strokeStyle = root.color;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            SequentialAnimation {
                running: root.running
                loops: Animation.Infinite
                NumberAnimation { target: canvas; property: "arcEnd"; from: 0.25; to: 0.75; duration: 600; easing.type: Easing.InOutCubic }
                NumberAnimation { target: canvas; property: "arcEnd"; from: 0.75; to: 0.25; duration: 600; easing.type: Easing.InOutCubic }
            }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: root.duration
                loops: Animation.Infinite
                running: root.running
                easing.type: Easing.Linear
            }
        }
    }

    Text {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: spinner.bottom
        anchors.topMargin: root.spacing
        text: root.text
        color: root.textColor
        font.pixelSize: root.textSize
        font.weight: Font.Medium
        visible: root.text.length > 0
        horizontalAlignment: Text.AlignHCenter
    }
}
