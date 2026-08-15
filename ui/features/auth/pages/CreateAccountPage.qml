import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color pageColor: "#FFFFFF"
    property color surfaceColor: "#F5F5F5"
    property color softBlueColor: "#EFF6FF"
    property color softGreenColor: "#ECFDF5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    anchors.fill: parent

    Component.onCompleted: {
        if (AppSettings.isLoggedIn())
            NavUtils.navigateToProfile();
    }

    background: Rectangle {
        color: root.pageColor
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 48
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ColumnLayout {
            id: contentColumn
            width: Math.min(parent.width - 40, 440)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 28
            spacing: 18

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 176
                radius: 18
                color: root.softBlueColor
                border.color: "#DBEAFE"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10


                    Label {
                        text: "Find your next place with confidence"
                        color: root.textColor
                        font.pixelSize: 25
                        font.bold: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Create an account to save accommodation options, manage bookings, and receive important updates."
                        color: root.mutedColor
                        font.pixelSize: 13
                        lineHeight: 1.12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: benefitsColumn.implicitHeight + 28
                radius: 16
                color: root.pageColor
                border.color: root.borderColor
                border.width: 1

                ColumnLayout {
                    id: benefitsColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 14
                    spacing: 12

                    Label {
                        text: "Your account helps you"
                        color: root.textColor
                        font.pixelSize: 15
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Repeater {
                        model: [
                            "Keep booking details in one place",
                            "Receive verification and security updates",
                            "Contact landlords and agents more easily"
                        ]

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                radius: 12
                                color: root.softGreenColor

                                Text {
                                    anchors.centerIn: parent
                                    text: "OK"
                                    color: "#166534"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }

                            Label {
                                text: modelData
                                color: root.mutedColor
                                font.pixelSize: 13
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            Button {
                id: createButton
                text: "Create account"
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.topMargin: 8

                contentItem: Text {
                    text: createButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: createButton.down ? "#1D4ED8" : root.primaryColor
                }

                onClicked: NavUtils.navigateToSignUp()
            }

            Button {
                id: signInButton
                text: "Sign in"
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                contentItem: Text {
                    text: signInButton.text
                    color: root.primaryColor
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: signInButton.down ? root.softBlueColor : root.pageColor
                    border.color: root.primaryColor
                    border.width: 1
                }

                onClicked: NavUtils.navigateToSignIn()
            }

        }
    }
}
