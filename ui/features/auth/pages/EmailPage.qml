import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property string email: emailField.text
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
        spacing: 10

        Label {
            text: "Add your email"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Booking alerts, receipts, and account recovery will be sent here."
            color: root.mutedColor
            font.pixelSize: 14
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -6
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            spacing: 7

            AuthTextField {
                id: emailField
                label: "Email address"
                placeholder: "name@example.com"
                required: true
                enabled: !root.busy
            }
        }

        AuthInfoCard {
            cardColor: "#EFF6FF"
            cardBorderColor: "#BFDBFE"
            accentColor: root.primaryColor
            message: "Use a working email"
            messageColor: "#1E40AF"
            circleSize: 36
            iconPixelSize: 18
            cardHeight: 60
            cardBorderWidth: 1
        }

        AuthErrorLabel {
            id: errorText
        }

        AuthContinueButton {
            id: continueButton
            busy: root.busy
            busyText: "Checking email..."
            onClicked: {
                if (emailField.text.trim().length === 0 || emailField.text.indexOf("@") === -1) {
                    errorText.text = "Enter a valid email address.";
                    return;
                }

                errorText.text = "";
                root.nextRequested();
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            radius: 12
            color: root.surfaceColor

            Label {
                anchors.fill: parent
                anchors.margins: 14
                text: "Use the same email you want to receive booking and verification messages on."
                color: root.mutedColor
                font.pixelSize: 12
                lineHeight: 1.1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}