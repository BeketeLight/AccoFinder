import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: skeleton
    color: "#E0E0E0"
    radius: 4
    clip: true

    property bool loading: true

    Rectangle {
        id: lightEffect
        width: parent.width * 0.6
        height: parent.height
        visible: skeleton.loading

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: "#40FFFFFF" } // Soft shimmer light
            GradientStop { position: 1.0; color: "transparent" }
        }

        NumberAnimation on x {
            from: -lightEffect.width
            to: skeleton.width
            duration: 1200
            loops: Animation.Infinite
            running: skeleton.loading && skeleton.visible
        }
    }
}