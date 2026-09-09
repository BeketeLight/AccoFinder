import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Primary "Continue" button shared by every auth wizard page. Handles the
// standard busy / disabled color variants in one place.
Button {
    id: root

    property string busyText: "Continue"
    property bool busy: false
    property color primaryColor: "#2563EB"
    property color primaryDarkColor: "#1D4ED8"

    text: root.busy ? root.busyText : "Continue"
    enabled: !root.busy
    Layout.fillWidth: true
    Layout.preferredHeight: 52
    Layout.topMargin: 6

    contentItem: Text {
        text: root.text
        color: "#FFFFFF"
        font.pixelSize: 15
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 12
        color: !root.enabled ? "#93C5FD"
               : root.down ? root.primaryDarkColor
               : root.primaryColor
    }
}