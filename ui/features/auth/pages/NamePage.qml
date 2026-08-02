import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string firstName: firstNameField.text
    property string lastName: lastNameField.text
    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: "Start with your name"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "This helps keep accommodation requests clear and trustworthy."
            color: root.mutedColor
            font.pixelSize: 14
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -6
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            radius: 12
            color: "#ECFDF5"
            border.color: "#BBF7D0"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 17
                    color: root.secondaryColor

                    Text {
                        anchors.centerIn: parent
                        text: "ID"
                        color: "#FFFFFF"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Label {
                    text: "Use the same names you use when contacting landlords or agents."
                    color: "#166534"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 7

            Label {
                text: "First name"
                color: root.textColor
                font.pixelSize: 13
                font.bold: true
            }

            TextField {
                id: firstNameField
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                placeholderText: "Enter first name"
                color: root.textColor
                placeholderTextColor: "#9CA3AF"
                font.pixelSize: 15
                selectByMouse: true
                verticalAlignment: Text.AlignVCenter
                leftPadding: 14
                rightPadding: 14
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: firstNameField.activeFocus ? root.primaryColor : root.borderColor
                    border.width: firstNameField.activeFocus ? 2 : 1
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 7

            Label {
                text: "Last name"
                color: root.textColor
                font.pixelSize: 13
                font.bold: true
            }

            TextField {
                id: lastNameField
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                placeholderText: "Enter last name"
                color: root.textColor
                placeholderTextColor: "#9CA3AF"
                font.pixelSize: 15
                selectByMouse: true
                verticalAlignment: Text.AlignVCenter
                leftPadding: 14
                rightPadding: 14
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: lastNameField.activeFocus ? root.primaryColor : root.borderColor
                    border.width: lastNameField.activeFocus ? 2 : 1
                }
            }
        }

        Label {
            id: errorText
            visible: text.length > 0
            text: ""
            color: root.errorColor
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Button {
            id: continueButton
            text: "Continue"
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            Layout.topMargin: 6

            contentItem: Text {
                text: continueButton.text
                color: "#FFFFFF"
                font.pixelSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 12
                color: continueButton.down ? "#1D4ED8" : root.primaryColor
            }

            onClicked: {
                if (firstNameField.text.trim().length === 0 || lastNameField.text.trim().length === 0) {
                    errorText.text = "Enter both first and last name.";
                    return;
                }

                errorText.text = "";
                root.nextRequested();
            }
        }
    }
}
