import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule

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

    function goBack() {
        if (currentStep > 0) {
            currentStep -= 1;
            return;
        }

        UtilsModule.NavigationUtils.pop();
    }

    function fullName() {
        return (nameStep.firstName + " " + nameStep.lastName).trim();
    }

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
                onClicked: root.goBack()
            }

            Label {
                text: "Acco Finder"
                color: root.textColor
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                text: (root.currentStep + 1) + "/4"
                color: root.mutedColor
                font.pixelSize: 13
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
            anchors.topMargin: 24
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 142
                radius: 18
                color: root.softBlueColor
                border.color: "#DBEAFE"
                border.width: 1

                Rectangle {
                    width: 42
                    height: 42
                    radius: 21
                    color: root.secondaryColor
                    opacity: 0.18
                    anchors.right: parent.right
                    anchors.rightMargin: 22
                    anchors.top: parent.top
                    anchors.topMargin: 18
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 62
                        Layout.preferredHeight: 62
                        radius: 18
                        color: root.pageColor
                        border.color: "#BFDBFE"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "AF"
                            color: root.primaryColor
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            color: root.secondaryColor
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            border.color: root.pageColor
                            border.width: 2
                        }
                    }

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
                        model: 4

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
                              : root.currentStep === 1 ? "Email verification"
                              : root.currentStep === 2 ? "Password setup"
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
                        color: root.currentStep === 3 ? root.softGreenColor : root.softBlueColor
                        border.color: root.currentStep === 3 ? "#BBF7D0" : "#BFDBFE"

                        Label {
                            anchors.centerIn: parent
                            text: (root.currentStep + 1) + " of 4"
                            color: root.currentStep === 3 ? "#166534" : root.primaryColor
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                Label {
                    text: root.currentStep === 0 ? "Only names are collected in this step."
                          : root.currentStep === 1 ? "The backend email verification call should attach here."
                          : root.currentStep === 2 ? "Password is collected before OTP confirmation."
                          : "Enter the email code to finish account verification."
                    color: root.mutedColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: stepStack.implicitHeight + 28
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

                    EmailPage {
                        id: emailStep
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

                    PasswordPage {
                        id: passwordStep
                        primaryColor: root.primaryColor
                        secondaryColor: root.secondaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onNextRequested: {
                            console.log("TODO AuthController.signUp",
                                        root.fullName(),
                                        emailStep.email);
                            root.currentStep = 3;
                        }
                    }

                    OtpPage {
                        id: otpStep
                        email: emailStep.email
                        primaryColor: root.primaryColor
                        surfaceColor: root.surfaceColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        borderColor: root.borderColor
                        errorColor: root.errorColor
                        Layout.fillWidth: true
                        onConfirmed: UtilsModule.NavigationUtils.navigateToSignIn()
                    }
                }
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
}
