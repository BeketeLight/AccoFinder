import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property string firstName: firstNameField.text
    property string lastName: lastNameField.text
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: "Start with your name"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "This helps keep accommodation requests clear and trustworthy."
            color: root.mutedColor
            font.pixelSize: 14
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -6
        }

        AuthInfoCard {
            iconPixelSize: 11
            message: "Use the same names you use when contacting landlords or agents."
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 7
            AuthTextField {
                id: firstNameField
                label: "First name"
                placeholder: "Enter first name"
                required: true
            }
            AuthTextField {
                id: lastNameField
                label: "Last name"
                placeholder: "Enter last name"
                required: true
            }
        }

        AuthErrorLabel {
            id: errorText
        }

        AuthContinueButton {
            id: continueButton
            onClicked: {
                if (firstNameField.text.trim().length === 0 || lastNameField.text.trim().length === 0) {
                    errorText.text = "Enter both first and last name.";
                    return;
                }

                errorText.text = "";
                root.nextRequested();
            }
        }
    }
}