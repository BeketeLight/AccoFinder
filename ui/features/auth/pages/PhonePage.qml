import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property string phone: phoneField.text
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    function normalizedPhone() {
        return phoneField.text.trim().replace(/\s+/g, "");
    }

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
            text: "Add your phone"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Landlords and agents can use this number for booking follow-ups."
            color: root.mutedColor
            font.pixelSize: 14
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -6
        }

        AuthInfoCard {
            cardColor: "#EFF6FF"
            cardBorderColor: "#BFDBFE"
            accentColor: root.primaryColor
            iconText: "+265"
            iconPixelSize: 10
            message: "Use a number you can answer when arranging viewings or confirmations."
            messageColor: "#1E40AF"
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 7

            AuthTextField {
                id: phoneField
                label: "Phone number"
                placeholder: "e.g. +265 999 123 456"
                required: true
                helperText: "Include the country code when possible."
                Layout.preferredHeight: 94
            }
        }

        AuthErrorLabel {
            id: errorText
        }

        AuthContinueButton {
            id: continueButton
            onClicked: {
                const value = root.normalizedPhone();
                const digits = value.replace(/\D/g, "");

                if (value.length === 0) {
                    errorText.text = "Enter your phone number.";
                    return;
                }

                if (digits.length < 9) {
                    errorText.text = "Enter a valid phone number.";
                    return;
                }

                errorText.text = "";
                root.nextRequested();
            }
        }
    }
}