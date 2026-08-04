import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"


Item {
    id: root

    property string password: passwordField.text
    property string confirmPassword: confirmPasswordField.text
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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            radius: 12
            color: "#ECFDF5"
            border.color: "#BBF7D0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 17
                    color: root.secondaryColor

                    Text {
                        anchors.centerIn: parent
                        text: "8+"
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Label {
                    text: "Use at least 8 characters. Longer passwords are easier to protect."
                    color: "#166534"
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
                id: passwordField
                label: "Password"
                placeholder: "Create password"
                required: true
                fieldHeight: 52
                backgroundColor: root.surfaceColor
                textColor: root.textColor
                labelColor: root.textColor
                placeholderColor: "#9CA3AF"
                borderColor: root.borderColor
                focusColor: root.primaryColor
                errorColor: root.errorColor
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                Layout.topMargin: 12
            }

            AppTextInput {
                id: confirmPasswordField
                label: "Confirm password"
                placeholder: "Repeat password"
                required: true
                fieldHeight: 52
                backgroundColor: root.surfaceColor
                textColor: root.textColor
                labelColor: root.textColor
                placeholderColor: "#9CA3AF"
                borderColor: root.borderColor
                focusColor: root.primaryColor
                errorColor: root.errorColor
                Layout.fillWidth: true
                Layout.preferredHeight: 76
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
            text: "Continue to OTP"
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
