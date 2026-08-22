import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../utils" as UtilsModule
import "../../../components/dialogs"

Page {
    id: root

    property string email: ""
    property string purpose: "registration"
    property string initialError: ""
    property color primaryColor: "#2563EB"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"
    property bool busy: AuthController.isLoading
    property string pendingAction: ""

    anchors.fill: parent

    background: Rectangle {
        color: root.pageColor
    }

    header: ToolBar {
        contentHeight: 56

        background: Rectangle {
            color: root.pageColor

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: root.borderColor
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 20
            spacing: 10

            ToolButton {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                icon.source: "qrc:/ui/assets/back.png"
                icon.width: 20
                icon.height: 20
                icon.color: root.textColor
                onClicked: UtilsModule.NavigationUtils.pop()
            }

            Label {
                text: "Verify email"
                color: root.textColor
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
            }
        }
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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: otpStep.implicitHeight + 28
                radius: 16
                color: root.pageColor
                border.color: root.borderColor
                border.width: 1

                OtpPage {
                    id: otpStep
                    anchors.fill: parent
                    anchors.margins: 14
                    email: root.email
                    busy: root.busy
                    primaryColor: root.primaryColor
                    surfaceColor: root.surfaceColor
                    textColor: root.textColor
                    mutedColor: root.mutedColor
                    borderColor: root.borderColor
                    errorColor: root.errorColor
                    onConfirmed: root.verifyOtp()
                    onResendRequested: root.resendOtp()
                    Component.onCompleted: {
                        if (root.initialError.length > 0)
                            otpStep.setError(root.initialError);
                    }
                }
            }
        }
    }

    AppLoadingDialog {
        id: loadingDialog
    }

    function verifyOtp() {
        otpStep.clearError();
        root.pendingAction = "verifyOtp";
        AuthController.verifyOtp(root.email, otpStep.otpCode, root.purpose);
    }

    function resendOtp() {
        otpStep.clearError();
        otpStep.clearOtp();
        root.pendingAction = "resendOtp";
        AuthController.requestOtp(root.email, root.purpose);
    }

    Connections {
        target: AuthController

        function onIsLoadingChanged(isLoading) {
            if (isLoading && root.pendingAction.length > 0)
                loadingDialog.open();
            else
                loadingDialog.close();
        }

        function onOtpVerified(status) {
            root.pendingAction = "";
            loadingDialog.close();

            if (status) {
                otpStep.clearError();
                UtilsModule.NavigationUtils.resetToSignIn();
            } else {
                otpStep.setError("Email verification failed. Check the code and try again.");
            }
        }

        function onOtpRequested(status) {
            root.pendingAction = "";
            loadingDialog.close();

            if (status)
                otpStep.clearError();
            else
                otpStep.setError("Could not resend the verification code. Try again.");
        }
    }

}
