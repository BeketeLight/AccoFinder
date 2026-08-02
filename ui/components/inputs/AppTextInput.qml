import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Public Properties

    property string text: ""
    property string label: ""
    property string placeholder: ""
    property string helperText: ""
    property bool enabled: true
    property bool required: false
    property bool password: false
    property bool error: false
    property int fieldHeight: 52
    property int borderRadius: 12

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

    implicitWidth: 280
    implicitHeight: {
        var h = height;
        if (label)
            h += labelItem.height + 6;
        if (helperText || error)
            h += 18;
        return h;
    }

    // Label

    Text {
        id: labelItem
        text: root.label + (root.required ? " *" : "")
        font.pixelSize: 13
        font.weight: Font.Medium
        color: root.error ? root.errorColor : root.labelColor
        visible: root.label.length > 0
    }

    // Input Field

    Rectangle {
        id: background
        anchors.top: root.label ? labelItem.bottom : parent.top
        anchors.topMargin: root.label ? 6 : 0
        width: parent.width
        height: root.fieldHeight
        radius: root.borderRadius
        color: root.enabled ? root.backgroundColor : "#EEEEEE"

        border.color: {
            if (root.error)
                return root.errorColor;
            if (textField.activeFocus)
                return root.focusColor;
            return root.borderColor;
        }
        border.width: textField.activeFocus || root.error ? 2 : 1

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }

        TextField {
            id: textField
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            text: root.text
            placeholderText: root.placeholder
            enabled: root.enabled
            echoMode: root.password ? TextInput.Password : TextInput.Normal
            color: root.textColor
            placeholderTextColor: root.placeholderColor
            font.pixelSize: 15
            selectByMouse: true
            verticalAlignment: Text.AlignVCenter
            // background: Item {}

            onTextChanged: {
                root.text = text;
                root.textEdited();
            }

            onAccepted: root.accepted()
            onEditingFinished: root.editingFinished()
        }
    }

    // Helper / Error Text

    Text {
        anchors.top: background.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 4
        text: root.error ? (root.helperText || "Invalid input") : root.helperText
        font.pixelSize: 12
        color: root.error ? root.errorColor : root.labelColor
        visible: root.helperText.length > 0 || root.error
    }
}
