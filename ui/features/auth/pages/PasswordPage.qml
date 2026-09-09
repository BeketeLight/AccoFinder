import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"


Item {
    id: root

    property string password: passwordField.text
    property string confirmPassword: confirmPasswordField.text
    property bool busy: false
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    function setError(message) {
        errorText.text = message || "";
    }

    function clearError() {
        errorText.text = "";
    }

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: "Secure your account"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Create password."
            color: root.mutedColor
            font.pixelSize: 14
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -6
        }

        AuthInfoCard {
            iconText: "8+"
            iconPixelSize: 12
            cardHeight: 64
            cardBorderWidth: 1
            message: "Use at least 8 characters. Longer passwords are easier to protect."
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 7

            AuthTextField {
                id: passwordField
                label: "Password"
                placeholder: "Create password"
                password: true
                required: true
                enabled: !root.busy
            }

            AuthTextField {
                id: confirmPasswordField
                label: "Confirm password"
                placeholder: "Repeat password"
                password: true
                required: true
                enabled: !root.busy
            }
        }

        AuthErrorLabel {
            id: errorText
        }

        AuthContinueButton {
            id: continueButton
            busy: root.busy
            busyText: "Creating account..."
            onClicked: {
                if (passwordField.text.length < 8) {
                    errorText.text = "Password should be at least 8 characters.";
                    return;
                }

                if (passwordField.text !== confirmPasswordField.text) {
                    errorText.text = "Passwords do not match.";
                    return;
                }

                errorText.text = "";
                root.nextRequested();
            }
        }
    }
}