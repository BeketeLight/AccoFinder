import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Colored informational tip card (icon circle + message) used throughout the
// auth wizard pages. All visual variants share the same structure; only colors,
// the icon glyph and the message change.
Rectangle {
    id: root

    property string message: ""
    property color messageColor: "#166534" // dark text matching the card accent
    property color accentColor: "#22C55E"  // icon circle color
    property color cardColor: "#ECFDF5"    // card background
    property color cardBorderColor: "#BBF7D0"
    property string iconText: "i"
    property int iconPixelSize: 14
    property int circleSize: 34
    property int cardHeight: 70
    property int cardBorderWidth: 0

    Layout.fillWidth: true
    Layout.preferredHeight: root.cardHeight
    radius: 12
    color: root.cardColor
    border.color: root.cardBorderColor
    border.width: root.cardBorderWidth

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Rectangle {
            Layout.preferredWidth: root.circleSize
            Layout.preferredHeight: root.circleSize
            radius: root.circleSize / 2
            color: root.accentColor

            Text {
                anchors.centerIn: parent
                text: root.iconText
                color: "#FFFFFF"
                font.pixelSize: root.iconPixelSize
                font.bold: true
            }
        }

        Label {
            text: root.message
            color: root.messageColor
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}