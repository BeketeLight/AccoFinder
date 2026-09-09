import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Hidden-until-non-empty error label used by the auth wizard pages. Callers
// validate, then set/clear `text` through the exposed id (e.g. errorLabel.text).
Label {
    id: root

    property color errorColor: "#EF4444"

    visible: text.length > 0
    text: ""
    color: root.errorColor
    font.pixelSize: 13
    wrapMode: Text.WordWrap
    Layout.fillWidth: true
}