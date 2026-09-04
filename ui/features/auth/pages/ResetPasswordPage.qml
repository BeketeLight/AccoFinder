import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/inputs"
import "../../../components/dialogs"

Page {
    id: root

    property string email: ""
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"
    property bool busy: AuthController.isLoading
    property string pageTitle: "Reset password"
    property bool showHeader: true
    property bool showBottomBorder: false

    anchors.fill: parent

    background: Rectangle {
        color: root.pageColor
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 56
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ColumnLayout {
            id: contentColumn
            width: Math.min(parent.width - 40, 440)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            spacing: 18

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 94

                Rectangle {
                    width: 72
                    height: 72
                    radius: 20
                    color: "#FEF2F2"

                    Text {
                        anchors.centerIn: parent
                        text: "\uD83D\uDD12"
                        font.pixelSize: 32
                    }

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: root.secondaryColor
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        border.color: root.pageColor
                        border.width: 3
                    }
                }
            }

            Label {
                text: "Create a new password"
                color: root.textColor
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                text: "Enter your new password below."
                color: root.mutedColor
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.topMargin: -10
            }

            AppTextInput {
                id: newPasswordInput
                label: "New password"
                placeholder: "Enter new password"
                password: true
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
                id: confirmPasswordInput
                label: "Confirm password"
                placeholder: "Re-enter new password"
                password: true
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
            }

            Label {
                id: errorLabel
                visible: text.length > 0
                text: ""
                color: root.errorColor
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Label {
                id: successLabel
                visible: text.length > 0
                text: ""
                color: "#16A34A"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                id: resetButton
                text: root.busy ? "Resetting..." : "Reset password"
                enabled: !root.busy
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                contentItem: Text {
                    text: resetButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: !resetButton.enabled ? "#93C5FD"
                           : resetButton.down ? "#1D4ED8"
                           : root.primaryColor
                }

                onClicked: root.submitReset()
            }
        }
    }

    Shortcut {
        sequence: "Return"
        enabled: !root.busy
        onActivated: root.submitReset()
    }

    AppLoadingDialog {
        id: loadingDialog
        title: "Resetting password"
        message: "Updating your password..."
    }

    function submitReset() {
        if (root.busy)
            return;

        const newPass = newPasswordInput.text;
        const confirmPass = confirmPasswordInput.text;

        if (newPass.length === 0) {
            errorLabel.text = "Enter a new password.";
            return;
        }

        if (newPass.length < 6) {
            errorLabel.text = "Password must be at least 6 characters.";
            return;
        }

        if (newPass !== confirmPass) {
            errorLabel.text = "Passwords do not match.";
            return;
        }

        errorLabel.text = "";
        successLabel.text = "";
        AuthController.resetPassword(root.email, newPass);
    }

    Connections {
        target: AuthController

        function onIsLoadingChanged(isLoading) {
            if (isLoading)
                loadingDialog.open();
            else
                loadingDialog.close();
        }

        function onPasswordReset(status) {
            loadingDialog.close();
            if (status) {
                errorLabel.text = "";
                successLabel.text = "Password reset successfully! Redirecting to sign in...";
                resetTimer.start();
            } else {
                errorLabel.text = "Failed to reset password. Please try again.";
                successLabel.text = "";
            }
        }
    }

    Timer {
        id: resetTimer
        interval: 2000
        repeat: false
        onTriggered: NavUtils.resetToSignIn()
    }
}
