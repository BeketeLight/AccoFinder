import QtQuick
import QtQuick.Controls

Button {
    id: button

    // ---- Public API ----
    property color customBackgroundColor: "#2563EB"
    property color customTextColor: "#FFFFFF"
    property real customRadius: 8
    property string customText: qsTr("change me")
    property color customBorderColor: "transparent"
    property int customBorderWidth: 0

    text: button.customText

    contentItem: Text {
        text: button.text
        font: button.font
        color: button.customTextColor
        opacity: button.enabled ? 1.0 : 0.4
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        // IMPORTANT: no implicitWidth / implicitHeight here.
        // The Button sizes its background; setting the background's
        // implicit size to the Button's own implicit size creates a
        // feedback loop, because Button.implicitWidth is derived from
        // background.implicitWidth + insets.
        radius: button.customRadius
        color: button.customBackgroundColor
        opacity: button.enabled ? 1.0 : 0.4
        border.color: button.customBorderColor
        border.width: button.customBorderWidth
    }
}
