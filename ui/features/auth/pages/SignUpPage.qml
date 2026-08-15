import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
import "../../../components/dialogs"

Page {
    id: root

    property int currentStep: 0
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color softBlueColor: "#EFF6FF"
    property color softGreenColor: "#ECFDF5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color warningColor: "#F59E0B"
    property color errorColor: "#EF4444"
    property bool busy: AuthController.isLoading

    // Tracks which auth action is in flight so signal handlers know what to do.
    property string pendingAction: ""

    function goBack() {
        if (root.busy)
            return;

        if (currentStep > 0) {
            currentStep -= 1;
            return;
        }

        UtilsModule.NavigationUtils.pop();
    }

    function fullName() {
        return (nameStep.firstName + " " + nameStep.lastName).trim();
    }

    function submitEmailStep() {
        emailStep.clearError();
        root.pendingAction = "checkAccount";
        AuthController.checkAccount(emailStep.email.trim());
    }

    function submitSignUp() {
        passwordStep.clearError();

        const area = locationStep.location.trim();
        if (area.length === 0) {
            // Location is collected earlier; if somehow empty, send user back.
            passwordStep.setError("Your area is required. Go back and enter a location.");
            root.currentStep = 1;
            return;
        }

        root.pendingAction = "signUp";
        AuthController.signUp(
            nameStep.firstName.trim(),
            nameStep.lastName.trim(),
            emailStep.email.trim(),
            passwordStep.password,
            passwordStep.confirmPassword,
            area
        );
    }

    function submitOtpVerification() {
        otpStep.clearError();
        root.pendingAction = "verifyEmail";
        AuthController.verifyEmail(emailStep.email.trim());
    }

    function resendVerification() {
        otpStep.clearError();
        root.pendingAction = "resendEmail";
        AuthController.verifyEmail(emailStep.email.trim());
    }

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
            anchors.topMargin: 24
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 142
                radius: 18
                color: root.softBlueColor
                border.color: "#DBEAFE"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14


                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "Create your account"
                            color: root.textColor
                            font.pixelSize: 25
                            font.bold: true
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "A guided setup for safer accommodation search and booking updates."
                            color: root.mutedColor
                            font.pixelSize: 13
                            lineHeight: 1.12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: 5

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: index <= root.currentStep ? root.primaryColor : root.borderColor

                            Behavior on color {
                                ColorAnimation {
                                    duration: 160
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: root.currentStep === 0 ? "Personal details"
                              : root.currentStep === 1 ? "Your location"
                              : root.currentStep === 2 ? "Email verification"
                              : root.currentStep === 3 ? "Password setup"
                              : "Confirm OTP"
                        color: root.textColor
                        font.pixelSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 28
                        radius: 14
                        color: root.currentStep === 4 ? root.softGreenColor : root.softBlueColor
                        border.color: root.currentStep === 4 ? "#BBF7D0" : "#BFDBFE"

                        Label {
                            anchors.centerIn: parent
                            text: (root.currentStep + 1) + " of 5"
                            color: root.currentStep === 4 ? "#166534" : root.primaryColor
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                Label {
                    text: root.currentStep === 0 ? "Only names are collected in this step."
                          : root.currentStep === 1 ? "Your area helps filter nearby properties."
                          : root.currentStep === 2 ? "Email collection and verification."
                          : root.currentStep === 3 ? "Password is collected before OTP confirmation."
                          : "Enter the email code to finish account verification."
                    color: root.mutedColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: stepStack.implicitHeight + 15
                radius: 16
                color: root.pageColor
                border.color: root.borderColor
                border.width: 1

                StackLayout {
                    id: stepStack
                    anchors.fill: parent
                    anchors.margins: 14
                    currentIndex: root.currentStep

                    NamePage {
                        id: nameStep
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onNextRequested: root.currentStep = 1
                    }

                    LocationPage {
                        id: locationStep
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onNextRequested: root.currentStep = 2
                    }

                    EmailPage {
                        id: emailStep
                        busy: root.busy && root.pendingAction === "checkAccount"
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onNextRequested: root.submitEmailStep()
                    }

                    PasswordPage {
                        id: passwordStep
                        busy: root.busy && root.pendingAction === "signUp"
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onNextRequested: root.submitSignUp()
                    }

                    OtpPage {
                        id: otpStep
                        email: emailStep.email
                        busy: root.busy && (root.pendingAction === "verifyEmail"
                                            || root.pendingAction === "resendEmail")
                        primaryColor: root.primaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onConfirmed: root.submitOtpVerification()
                        onResendRequested: root.resendVerification()
                    }
                }
            }

            Button {
                id: previousStepButton
                text: "Back to previous step"
                visible: root.currentStep > 0
                enabled: !root.busy
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 48 : 0

                contentItem: Text {
                    text: previousStepButton.text
                    color: root.primaryColor
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: previousStepButton.down ? root.softBlueColor : root.pageColor
                    border.color: root.primaryColor
                    border.width: 1
                }

                onClicked: root.goBack()
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                radius: 12
                color: root.surfaceColor

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Label {
                        text: "Already have an account?"
                        color: root.mutedColor
                        font.pixelSize: 13
                    }

                    Label {
                        text: "Sign in"
                        color: root.primaryColor
                        font.pixelSize: 13
                        font.bold: true

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: UtilsModule.NavigationUtils.navigateToSignIn()
                        }
                    }
                }
            }
        }
    }

    AppLoadingDialog {
        id: loadingDialog
    }

    Connections {
        target: AuthController

        function onIsLoadingChanged(isLoading) {
            if (isLoading)
                loadingDialog.open();
            else
                loadingDialog.close();
        }

        function onAccountChecked(status) {
            if (root.pendingAction !== "checkAccount")
                return;

            root.pendingAction = "";
            loadingDialog.close();

            // status true means the account already exists.
            if (status) {
                emailStep.setError("An account with this email already exists. Sign in instead.");
                return;
            }

            emailStep.clearError();
            root.currentStep = 3;
        }

        function onSignUpSucceded(user) {
            if (root.pendingAction !== "signUp")
                return;

            root.pendingAction = "";
            loadingDialog.close();
            passwordStep.clearError();
            root.currentStep = 4;
        }

        function onSignUpFailed(message) {
            if (root.pendingAction !== "signUp")
                return;

            root.pendingAction = "";
            loadingDialog.close();
            passwordStep.setError(message)

        }

        function onEmailVerified(status) {
            if (root.pendingAction !== "verifyEmail" && root.pendingAction !== "resendEmail")
                return;

            const action = root.pendingAction;
            root.pendingAction = "";
            loadingDialog.close();

            if (action === "resendEmail") {
                if (status)
                    otpStep.setError(""); // clear any prior error; code re-sent
                else
                    otpStep.setError("Could not resend the verification code. Try again.");
                return;
            }

            if (status) {
                otpStep.clearError();
                UtilsModule.NavigationUtils.navigateToSignIn();
            } else {
                otpStep.setError("Email verification failed. Check the code and try again.");
            }
        }
    }
}
