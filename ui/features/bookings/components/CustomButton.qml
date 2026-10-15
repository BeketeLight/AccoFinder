import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: customBtn

    // --- Customizable Properties ---
    property color buttonColor: "#22C55E"
    property color pressedColor: Qt.darker(buttonColor, 1.15)
    property color textColor: "#FFFFFF"

    property color borderColor: "transparent"
    property int borderWidth: 0
    property int cornerRadius: 12

    property int fontPixelSize: 14
    property bool fontBold: true

    // Layout Sizing Defaults
    implicitHeight: 40
    implicitWidth: 120

    // Text Content Styling
    contentItem: Text {
        text: customBtn.text
        color: customBtn.enabled ? customBtn.textColor : "#94A3B8"
        font.pixelSize: customBtn.fontPixelSize
        font.bold: customBtn.fontBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Background Styling (Handles borders, radius, and pressed state)
    background: Rectangle {
        color: !customBtn.enabled
            ? "#E2E8F0"
            : (customBtn.pressed ? customBtn.pressedColor : customBtn.buttonColor)

        radius: customBtn.cornerRadius
        border.color: customBtn.borderColor
        border.width: customBtn.borderWidth

        // Subtle animation for pressing feedback
        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }
}