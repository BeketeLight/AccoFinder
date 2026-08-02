import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string email: emailField.text
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
            text: "Add your email"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: "Booking alerts, receipts, and account recovery will be sent here."
            color: root.mutedColor
            font.pixelSize: 14
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -6
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            spacing: 7

            Label {
                text: "Email address"
                color: root.textColor
                font.pixelSize: 13
                font.bold: true
            }

            TextField {
                id: emailField
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                placeholderText: "name@example.com"
                color: root.textColor
                placeholderTextColor: "#9CA3AF"
                font.pixelSize: 15
                inputMethodHints: Qt.ImhEmailCharactersOnly
                selectByMouse: true
                verticalAlignment: Text.AlignVCenter
                leftPadding: 14
                rightPadding: 14
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: emailField.activeFocus ? root.primaryColor : root.borderColor
                    border.width: emailField.activeFocus ? 2 : 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            radius: 12
            color: "#EFF6FF"
            border.color: "#BFDBFE"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: root.primaryColor

                    Text {
                        anchors.centerIn: parent
                        text: "@"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                Label {
                    text: "Controller owner should trigger backend email verification after this step."
                    color: "#1E40AF"
                    font.pixelSize: 13
                    lineHeight: 1.1
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
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
            text: "Send verification"
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
                if (emailField.text.trim().length === 0 || emailField.text.indexOf("@") === -1) {
                    errorText.text = "Enter a valid email address.";
                    return;
                }

                errorText.text = "";
                console.log("TODO AuthController request email verification", emailField.text);
                root.nextRequested();
            }
        }
    }
}
