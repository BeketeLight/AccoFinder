import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root

    // Public Properties
    property string text: ""
    property string label: ""
    property string placeholder: ""
    property string helperText: ""
    property bool required: false
    property bool password: false
    property bool error: false
    property int fieldHeight: 56
    property int fieldWidth: 280
    property int borderRadius: 12
    property int horizontalPadding: 14
    // Distance of the floating placeholder from the top edge of the field
    property int floatingLabelTopMargin: 5

    // Colors
    property color backgroundColor: "#F1F3F4"
    property color textColor: "#202124"
    property color labelColor: "#5F6368"
    property color placeholderColor: "#9AA0A6"
    property color borderColor: "#DADCE0"
    property color focusColor: "#1A73E8"
    property color errorColor: "#D93025"

    // Signals
    signal accepted
    signal textEdited
    signal editingFinished

    // fieldWidth is the default/implicit size only.
    // In Layouts, use Layout.fillWidth: true — the field fills the assigned width.
    implicitWidth: fieldWidth
    implicitHeight: {
        var h = fieldHeight
        if (label.length > 0)
            h += labelItem.implicitHeight + 6
        if (helperText.length > 0 || error)
            h += helperItem.implicitHeight + 4
        return h
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Text {
            id: labelItem
            Layout.fillWidth: true
            text: root.label + (root.required ? " *" : "")
            font.pixelSize: 13
            font.weight: Font.Medium
            color: root.error ? root.errorColor : root.labelColor
            visible: root.label.length > 0
        }

        TextField {
            id: textField

            // Avoid Material's own floating placeholder — we draw ours so
            // position can be controlled precisely (floatingLabelTopMargin).
            Material.containerStyle: Material.Filled
            Material.accent: root.error ? root.errorColor : root.focusColor
            Material.foreground: root.textColor

            readonly property bool isFloating: activeFocus || text.length > 0

            Layout.fillWidth: true
            Layout.preferredHeight: root.fieldHeight
            Layout.minimumHeight: root.fieldHeight
            Layout.maximumHeight: root.fieldHeight

            text: root.text
            // Built-in placeholder disabled; floatingLabel draws it instead
            placeholderText: ""
            enabled: root.enabled
            echoMode: root.password ? TextInput.Password : TextInput.Normal
            color: root.textColor
            font.pixelSize: 15
            selectByMouse: true

            leftPadding: root.horizontalPadding
            rightPadding: root.horizontalPadding
            // Leave room under the floating label for the typed text
            topPadding: isFloating ? root.floatingLabelTopMargin + 14 : 0
            bottomPadding: isFloating ? 8 : 0
            verticalAlignment: Text.AlignVCenter

            background: Item {
                Rectangle {
                    anchors.fill: parent
                    radius: root.borderRadius
                    color: root.enabled ? root.backgroundColor : Qt.lighter(root.backgroundColor, 1.05)
                    border.width: textField.activeFocus || root.error ? 2 : 1
                    border.color: {
                        if (root.error)
                            return root.errorColor
                        if (textField.activeFocus)
                            return root.focusColor
                        return root.borderColor
                    }
                }

                // Custom floating placeholder — sits exactly floatingLabelTopMargin
                // below the top edge when focused or when text is present.
                Text {
                    id: floatingLabel
                    text: root.placeholder
                    visible: root.placeholder.length > 0
                    color: {
                        if (root.error)
                            return root.errorColor
                        if (textField.activeFocus)
                            return root.focusColor
                        return root.placeholderColor
                    }
                    font.pixelSize: textField.isFloating ? 11 : 15
                    font.weight: textField.isFloating ? Font.Medium : Font.Normal

                    x: root.horizontalPadding
                    width: parent.width - root.horizontalPadding * 2
                    elide: Text.ElideRight

                    y: textField.isFloating
                       ? root.floatingLabelTopMargin
                       : Math.round((parent.height - height) / 2)

                    Behavior on y {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }
                }
            }

            onTextChanged: {
                if (root.text !== text)
                    root.text = text
                root.textEdited()
            }

            onAccepted: root.accepted()
            onEditingFinished: root.editingFinished()
        }

        Text {
            id: helperItem
            Layout.fillWidth: true
            Layout.leftMargin: 4
            text: root.error ? (root.helperText || "Invalid input") : root.helperText
            font.pixelSize: 12
            color: root.error ? root.errorColor : root.labelColor
            visible: root.helperText.length > 0 || root.error
            wrapMode: Text.WordWrap
        }
    }

    // Keep internal field in sync when text is set from outside
    onTextChanged: {
        if (textField.text !== root.text)
            textField.text = root.text
    }
}
