import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../../utils" as UtilsModule

Page {
    id: signUpPageId
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

            Item { Layout.fillWidth: true }  // Spacer
        }
    }

    // ===== MAIN CONTENT =====
    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 30
            leftMargin: 24
            rightMargin: 24
        }
        spacing: 24

        // Welcome Label
        Label {
            text: "Create Account"
            font.pixelSize: 28
            font.bold: true
            color: "#1F2937"
            Layout.fillWidth: true
        }

        Label {
            text: "Sign up to get started with AccoFinder"
            font.pixelSize: 14
            color: "#6B7280"
            Layout.fillWidth: true
            Layout.topMargin: -8
        }

        // Spacer
        Item {
            Layout.preferredHeight: 10
        }

        // Full Name Field
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: "Full Name"
                font {
                    pixelSize: 13
                    bold: true
                }
                color: "#374151"
                Layout.fillWidth: true
            }

            TextField {
                id: name
                placeholderText: "Enter your full name"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                font.pixelSize: 14
                color: "#1F2937"
                placeholderTextColor: "#94A3B8"

                background: Rectangle {
                    color: "#F8FAFC"
                    radius: 10
                    border.color: name.activeFocus ? "#2563EB" : "#E2E8F0"
                    border.width: name.activeFocus ? 2 : 1
                }
                padding: 12
                selectByMouse: true
            }
        }

        // Email Field
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: "Email"
                font {
                    pixelSize: 13
                    bold: true
                }
                color: "#374151"
                Layout.fillWidth: true
            }

            TextField {
                id: email
                placeholderText: "Enter your email"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                font.pixelSize: 14
                color: "#1F2937"
                placeholderTextColor: "#94A3B8"

                background: Rectangle {
                    color: "#F8FAFC"
                    radius: 10
                    border.color: email.activeFocus ? "#2563EB" : "#E2E8F0"
                    border.width: email.activeFocus ? 2 : 1
                }
                padding: 12
                selectByMouse: true
            }
        }

        // Password Field
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: "Password"
                font {
                    pixelSize: 13
                    bold: true
                }
                color: "#374151"
                Layout.fillWidth: true
            }

            TextField {
                id: password
                placeholderText: "Create a password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                font.pixelSize: 14
                color: "#1F2937"
                placeholderTextColor: "#94A3B8"

                background: Rectangle {
                    color: "#F8FAFC"
                    radius: 10
                    border.color: password.activeFocus ? "#2563EB" : "#E2E8F0"
                    border.width: password.activeFocus ? 2 : 1
                }
                padding: 12
                selectByMouse: true
            }
        }

        // Confirm Password Field
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: "Confirm Password"
                font {
                    pixelSize: 13
                    bold: true
                }
                color: "#374151"
                Layout.fillWidth: true
            }

            TextField {
                id: confirmPassword
                placeholderText: "Confirm your password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                font.pixelSize: 14
                color: "#1F2937"
                placeholderTextColor: "#94A3B8"

                background: Rectangle {
                    color: "#F8FAFC"
                    radius: 10
                    border.color: confirmPassword.activeFocus ? "#2563EB" : "#E2E8F0"
                    border.width: confirmPassword.activeFocus ? 2 : 1
                }
                padding: 12
                selectByMouse: true
            }
        }

        // Residential Address Field
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: "Residential Address"
                font {
                    pixelSize: 13
                    bold: true
                }
                color: "#374151"
                Layout.fillWidth: true
            }

            TextField {
                id: residentialAddress
                placeholderText: "Enter your residential address"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                font.pixelSize: 14
                color: "#1F2937"
                placeholderTextColor: "#94A3B8"

                background: Rectangle {
                    color: "#F8FAFC"
                    radius: 10
                    border.color: residentialAddress.activeFocus ? "#2563EB" : "#E2E8F0"
                    border.width: residentialAddress.activeFocus ? 2 : 1
                }
                padding: 12
                selectByMouse: true
            }
        }

        // Sign Up Button
        Button {
            id: signUpButtonId
            text: "SIGN UP"
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.topMargin: 8

            font {
                bold: true
                pixelSize: 15
                letterSpacing: 0.5
            }

            contentItem: Text {
                text: signUpButtonId.text
                font: signUpButtonId.font
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: "#2563EB"
                radius: 10

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = "#1D4ED8"
                    onExited: parent.color = "#2563EB"
                }
            }

            onClicked: {
                // Validation
                if (name.text === "" || email.text === "" || password.text === "" ||
                    confirmPassword.text === "" || residentialAddress.text === "") {
                    console.log("Please fill all fields")
                } else if (password.text !== confirmPassword.text) {
                    console.log("Passwords do not match")
                } else {
                    console.log("Sign up successful")
                    // Add navigation logic here
                }
            }
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

        // Google Sign Up Button
        Button {
            id: googleButton
            text: "Sign up with Google"
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
                console.log("Google Sign Up clicked")
            }
        }

        // Spacer
        Item {
            Layout.preferredHeight: 10
        }

        // Sign In Link
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Layout.alignment: Qt.AlignHCenter

            Label {
                text: "Already have an account?"
                color: "#6B7280"
                font.pixelSize: 13
            }

            Label {
                text: "Sign In"
                color: "#2563EB"
                font {
                    pixelSize: 13
                    bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UtilsModule.NavigationUtils.pop()
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
            if (name.activeFocus || email.activeFocus || password.activeFocus ||
                confirmPassword.activeFocus || residentialAddress.activeFocus) {
                signUpButtonId.clicked()
            }
        }
    }
}