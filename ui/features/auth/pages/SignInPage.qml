import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
import "../../../components/inputs"

Page {
    id: root

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

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
                text: "Acco Finder"
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

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 94

                Rectangle {
                    width: 72
                    height: 72
                    radius: 20
                    color: "#EFF6FF"

                    Text {
                        anchors.centerIn: parent
                        text: "A"
                        color: root.primaryColor
                        font.pixelSize: 32
                        font.bold: true
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
                text: "Sign in to continue finding safe and reliable accommodation."
                color: root.mutedColor
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.topMargin: -12
            }

            AppTextInput {
                id: emailInput
                label: "Email address"
                placeholder: "name@example.com"
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
                id: passwordInput
                label: "Password"
                placeholder: "Enter your password"
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

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: rememberCheck
                    text: "Remember me"
                    checked: true
                    font.pixelSize: 13
                    contentItem: Text {
                        text: rememberCheck.text
                        color: root.mutedColor
                        font: rememberCheck.font
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: rememberCheck.indicator.width + rememberCheck.spacing
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Label {
                    text: "Forgot password?"
                    color: root.primaryColor
                    font.pixelSize: 13
                    font.bold: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: UtilsModule.NavigationUtils.navigateToForgotPassword()
                    }
                }
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

            Button {
                id: signInButton
                text: "Sign in"
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                contentItem: Text {
                    text: signInButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: signInButton.down ? "#1D4ED8" : root.primaryColor
                }

                onClicked: {
                    if (emailInput.text.trim().length === 0 || passwordInput.text.length === 0) {
                        errorLabel.text = "Enter your email and password to continue.";
                        return;
                    }

                    errorLabel.text = "";
                    console.log("TODO AuthController.signIn", emailInput.text);
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.borderColor
                }

                Label {
                    text: "or"
                    color: root.mutedColor
                    font.pixelSize: 12
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.borderColor
                }
            }

            Button {
                id: googleButton
                text: "Continue with Google"
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                contentItem: RowLayout {
                    spacing: 10

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        radius: 12
                        color: "#FFFFFF"
                        border.color: root.borderColor
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "G"
                            color: "#1F2937"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    Text {
                        text: googleButton.text
                        color: root.textColor
                        font.pixelSize: 15
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                background: Rectangle {
                    radius: 12
                    color: googleButton.down ? root.surfaceColor : root.pageColor
                    border.color: root.borderColor
                    border.width: 1
                }

                onClicked: console.log("TODO AuthController.signInWithGoogle")
            }

            Button {
                id: createButton
                text: "Create an account"
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                contentItem: Text {
                    text: createButton.text
                    color: root.primaryColor
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: createButton.down ? "#EFF6FF" : root.pageColor
                    border.color: root.primaryColor
                    border.width: 1
                }

                onClicked: UtilsModule.NavigationUtils.navigateToSignUp()
            }
        }
    }

    Shortcut {
        sequence: "Return"
        onActivated: signInButton.clicked()
    }
}
