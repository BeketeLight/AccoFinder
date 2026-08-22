import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"

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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            radius: 12
            color: "#EFF6FF"
            border.color: "#BFDBFE"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 17
                    color: root.primaryColor

                    Text {
                        anchors.centerIn: parent
                        text: "+265"
                        color: "#FFFFFF"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                Label {
                    text: "Use a number you can answer when arranging viewings or confirmations."
                    color: "#1E40AF"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 7

            AppTextInput {
                id: phoneField
                label: "Phone number"
                placeholder: "e.g. +265 999 123 456"
                required: true
                fieldHeight: 52
                backgroundColor: root.surfaceColor
                textColor: root.textColor
                labelColor: root.textColor
                placeholderColor: "#9CA3AF"
                borderColor: root.borderColor
                focusColor: root.primaryColor
                errorColor: root.errorColor
                helperText: "Include the country code when possible."
                Layout.fillWidth: true
                Layout.preferredHeight: 94
                Layout.topMargin: 12
            }
        }

        Label {
            id: errorText
            visible: text.length > 0
            text: ""
            color: root.errorColor
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Button {
            id: continueButton
            text: "Continue"
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            Layout.topMargin: 6

            contentItem: Text {
                text: continueButton.text
                color: "#FFFFFF"
                font.pixelSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 12
                color: continueButton.down ? "#1D4ED8" : root.primaryColor
            }

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
