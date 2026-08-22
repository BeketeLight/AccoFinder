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
    readonly property string otpPurpose: "registration"

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
        const phone = phoneStep.normalizedPhone();
        if (area.length === 0) {
            // Location is collected earlier; if somehow empty, send user back.
            passwordStep.setError("Your area is required. Go back and enter a location.");
            root.currentStep = 1;
            return;
        }

        if (phone.length === 0) {
            passwordStep.setError("Your phone number is required. Go back and enter a phone number.");
            root.currentStep = 2;
            return;
        }

        root.pendingAction = "signUp";
        AuthController.signUp(
                    nameStep.firstName.trim(),
                    nameStep.lastName.trim(),
                    emailStep.email.trim(),
                    phone,
                    passwordStep.password,
                    passwordStep.confirmPassword,
                    area
                    );
    }

    function requestRegistrationOtp(pendingAction) {
        otpStep.clearError();
        root.pendingAction = pendingAction;
        AuthController.requestOtp(emailStep.email.trim(), root.otpPurpose);
    }

    function submitOtpVerification() {
        otpStep.clearError();
        root.pendingAction = "verifyOtp";
        AuthController.verifyOtp(emailStep.email.trim(), otpStep.otpCode, root.otpPurpose);
    }

    function resendVerification() {
        otpStep.clearOtp();
        root.requestRegistrationOtp("resendOtp");
    }

    function isExistingAccountMessage(message) {
        const normalizedMessage = (message || "").toLowerCase();
        const mentionsAccount = normalizedMessage.indexOf("account") !== -1
                              || normalizedMessage.indexOf("email") !== -1
                              || normalizedMessage.indexOf("user") !== -1;
        const mentionsDuplicate = normalizedMessage.indexOf("exist") !== -1
                                || normalizedMessage.indexOf("already") !== -1
                                || normalizedMessage.indexOf("registered") !== -1;
        return mentionsAccount && mentionsDuplicate;
    }

    function continueExistingAccountVerification() {
        emailStep.clearError();
        passwordStep.clearError();
        otpStep.clearError();
        root.requestRegistrationOtp("requestOtpExisting");
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
                        model: 6

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
                                                                              : root.currentStep === 2 ? "Phone contact"
                                                                                                       : root.currentStep === 3 ? "Email verification"
                                                                                                                                : root.currentStep === 4 ? "Password setup"
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
                        color: root.currentStep === 5 ? root.softGreenColor : root.softBlueColor
                        border.color: root.currentStep === 5 ? "#BBF7D0" : "#BFDBFE"

                        Label {
                            anchors.centerIn: parent
                            text: (root.currentStep + 1) + " of 6"
                            color: root.currentStep === 5 ? "#166534" : root.primaryColor
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                Label {
                    text: root.currentStep === 0 ? "Only names are collected in this step."
                                                 : root.currentStep === 1 ? "Your area helps filter nearby properties."
                                                                          : root.currentStep === 2 ? "Your phone number helps with viewing and booking follow-ups."
                                                                                                   : root.currentStep === 3 ? "Email collection and verification."
                                                                                                                            : root.currentStep === 4 ? "Password is collected before OTP confirmation."
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

                    PhonePage {
                        id: phoneStep
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onNextRequested: root.currentStep = 3
                    }

                    EmailPage {
                        id: emailStep
                        busy: root.busy && (root.pendingAction === "checkAccount"
                                            || root.pendingAction === "requestOtpExisting")
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
                        busy: root.busy && (root.pendingAction === "signUp"
                                            || root.pendingAction === "requestOtpAfterSignUp")
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
                        busy: root.busy && (root.pendingAction === "verifyOtp"
                                            || root.pendingAction === "resendOtp")
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
            if (isLoading && root.pendingAction.length > 0)
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
                root.continueExistingAccountVerification();
                return;
            }

            emailStep.clearError();
            root.currentStep = 4;
        }

        function onSignUpSucceded(user) {
            if (root.pendingAction !== "signUp")
                return;

            loadingDialog.close();
            passwordStep.clearError();
            // Just request OTP - navigation will happen in onOtpRequested
            root.requestRegistrationOtp("requestOtpAfterSignUp");
        }

        function onSignUpFailed(message) {
            if (root.pendingAction !== "signUp")
                return;

            root.pendingAction = "";
            loadingDialog.close();
            if (root.isExistingAccountMessage(message)) {
                root.continueExistingAccountVerification();
                return;
            }

            passwordStep.setError(message)

        }

        function onOtpRequested(status) {
            if (root.pendingAction !== "requestOtpAfterSignUp"
                    && root.pendingAction !== "requestOtpExisting"
                    && root.pendingAction !== "resendOtp")
                return;

            const action = root.pendingAction;
            root.pendingAction = "";
            loadingDialog.close();

            if (action === "resendOtp") {
                if (status)
                    otpStep.clearError();
                else
                    otpStep.setError("Could not resend the verification code. Try again.");
                return;
            }

            // Always navigate to OTP screen regardless of status
            // If status is false, pass an error message
            const errorMessage = status ? "" : "Could not send the verification code. Please try again using the resend option.";

            // Navigate to OTP page
            UtilsModule.NavigationUtils.navigateToOtp(
                emailStep.email.trim().toLowerCase(),  // Ensure lowercase
                root.otpPurpose,
                errorMessage
            );

            // If it was an existing account case and failed, we need to handle differently
            if (!status && action === "requestOtpExisting") {
                // The OTP page will show the error message
                // The user can manually request OTP again from the OTP page
            }
        }
        function onOtpVerified(status) {
            if (root.pendingAction !== "verifyOtp")
                return;

            root.pendingAction = "";
            loadingDialog.close();

            if (status) {
                otpStep.clearError();
                UtilsModule.NavigationUtils.resetToSignIn();
            } else {
                otpStep.setError("Email verification failed. Check the code and try again.");
            }
        }

    }
}
