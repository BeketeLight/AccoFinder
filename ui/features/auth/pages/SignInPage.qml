import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../../../utils" as UtilsModule
import "../../../components/buttons"
import "../../../components/inputs"
import "../../../components/indicators"

Page {
    id: signInPage
    anchors.fill: parent
    background: Rectangle {
        color: "#F5F7FA"  // Soft background
    }

    // ===== HEADER WITH BACK BUTTON =====
    header: ToolBar {
        background: Rectangle {
            color: "#FFFFFF"
            // Simple shadow line
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 1
                color: "#E2E8F0"
            }
        }

        contentHeight: 56

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            // Back Button
            ToolButton {
                Image {
                    id: home
                    width: 24
                    height: 24
                    source: "qrc:/ui/assets/back.png"
                    fillMode: Image.PreserveAspectFit
                    Layout.alignment: Qt.AlignHCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: UtilsModule.NavigationUtils.pop()
                    }
                }
                onClicked: UtilsModule.NavigationUtils.pop()
            }

            // App Title
            Label {
                text: "AccoFinder"
                font {
                    pixelSize: 18
                    bold: true
                }
                color: "#1F2937"
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
        }
    }

    // ===== MAIN CONTENT =====
    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 40
            leftMargin: 24
            rightMargin: 24
        }
        spacing: 10

        // Welcome Label
        Label {
            text: "Welcome Back"
            font.pixelSize: 28
            font.bold: true
            color: "#1F2937"
            Layout.fillWidth: true
        }

        Label {
            text: "Sign in to continue"
            font.pixelSize: 14
            color: "#6B7280"
            Layout.fillWidth: true
            Layout.topMargin: -8
        }

        // Spacer
        Item {
            Layout.preferredHeight: 10
        }

        // Email Field
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            TextInput {
                label: "Email"
                password: false
                placeholder: "Enter your email"
            }
             // Password Field
            TextInput {
                label: "Password"
                password: true
                placeholder: "Enter your password"
            }
        }

        // Forgot Password
        Label {
            text: "Forgot Password?"
            color: "#2563EB"
            font {
                pixelSize: 12
                bold: true
            }
            Layout.alignment: Qt.AlignRight
            Layout.topMargin: -8

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Navigate to forgot password
                    console.log("Forgot Password clicked")
                }
            }
        }

        // Sign In Button
        PrimaryButton {
            id: signinBtn
            customText: "Sing in"
        }

        // OR Divider
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E2E8F0"
            }

            Label {
                text: "OR"
                color: "#94A3B8"
                font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E2E8F0"
            }
        }

        // Google Sign In Button
        Button {
            id: googleButton
            text: ""
            Layout.fillWidth: true
            Layout.preferredHeight: 48

            font {
                bold: true
                pixelSize: 14
            }

            contentItem: Text {
                text: googleButton.text
                font: googleButton.font
                color: "#1F2937"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: "#FFFFFF"
                radius: 10
                border.color: "#E2E8F0"
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = "#F8FAFC"
                    onExited: parent.color = "#FFFFFF"
                }
            }

            onClicked: {
                console.log("Google Sign In clicked")
            }
        }

        // Spacer
        Item {
            Layout.preferredHeight: 10
        }

        // Sign Up Link
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Layout.alignment: Qt.AlignHCenter

            Label {
                text: "Don't have an account?"
                color: "#6B7280"
                font.pixelSize: 13
            }

            Label {
                text: "Sign Up"
                color: "#2563EB"
                font {
                    pixelSize: 13
                    bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UtilsModule.NavigationUtils.navigateToSignUp()
                }
            }
        }

        // Bottom spacer
        Item {
            Layout.fillHeight: true
        }
    }

    // Keyboard handling for Enter key
    Shortcut {
        sequence: "Return"
        onActivated: {
            if (email.activeFocus || password.activeFocus) {
                signinButtonId.clicked()
            }
        }
    }
}