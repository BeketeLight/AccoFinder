import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"

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
        spacing: 10

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

            AppTextInput {
                id: emailField
                label: "Email address"
                placeholder: "name@example.com"
                //Layout.fillWidth: true
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

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
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
                        text: "i"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                Label {
                    text: "Use a working email"
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
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            radius: 12
            color: root.surfaceColor

            Label {
                anchors.fill: parent
                anchors.margins: 14
                text: "Use the same email you want to receive booking and verification messages on."
                color: root.mutedColor
                font.pixelSize: 12
                lineHeight: 1.1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
