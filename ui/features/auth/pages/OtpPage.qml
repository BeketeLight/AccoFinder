import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string email: ""
    property string otpCode: digitOne.text + digitTwo.text + digitThree.text + digitFour.text + digitFive.text + digitSix.text
    property color primaryColor: "#2563EB"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal confirmed
    signal resendRequested

    implicitHeight: layout.implicitHeight

    function focusNext(field, nextField) {
        if (field.text.length === 1 && nextField) {
            nextField.forceActiveFocus();
        }
    }

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 16

        Label {
            text: "Enter OTP"
            color: root.textColor
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: root.email.length > 0
                  ? "Type the 6-digit code sent to " + root.email + "."
                  : "Type the 6-digit verification code sent to your email."
            color: root.mutedColor
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -8
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 14
            spacing: 8

            TextField {
                id: digitOne
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 1
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: digitOne.activeFocus ? root.primaryColor : root.borderColor
                    border.width: digitOne.activeFocus ? 2 : 1
                }
                onTextChanged: root.focusNext(digitOne, digitTwo)
            }

            TextField {
                id: digitTwo
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 1
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: digitTwo.activeFocus ? root.primaryColor : root.borderColor
                    border.width: digitTwo.activeFocus ? 2 : 1
                }
                onTextChanged: root.focusNext(digitTwo, digitThree)
            }

            TextField {
                id: digitThree
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 1
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: digitThree.activeFocus ? root.primaryColor : root.borderColor
                    border.width: digitThree.activeFocus ? 2 : 1
                }
                onTextChanged: root.focusNext(digitThree, digitFour)
            }

            TextField {
                id: digitFour
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 1
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: digitFour.activeFocus ? root.primaryColor : root.borderColor
                    border.width: digitFour.activeFocus ? 2 : 1
                }
                onTextChanged: root.focusNext(digitFour, digitFive)
            }

            TextField {
                id: digitFive
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 1
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: digitFive.activeFocus ? root.primaryColor : root.borderColor
                    border.width: digitFive.activeFocus ? 2 : 1
                }
                onTextChanged: root.focusNext(digitFive, digitSix)
            }

            TextField {
                id: digitSix
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 1
                background: Rectangle {
                    radius: 12
                    color: root.surfaceColor
                    border.color: digitSix.activeFocus ? root.primaryColor : root.borderColor
                    border.width: digitSix.activeFocus ? 2 : 1
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
            id: confirmButton
            text: "Verify account"
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            Layout.topMargin: 6

            contentItem: Text {
                text: confirmButton.text
                color: "#FFFFFF"
                font.pixelSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 12
                color: confirmButton.down ? "#1D4ED8" : root.primaryColor
            }

            onClicked: {
                if (root.otpCode.length !== 6) {
                    errorText.text = "Enter the full 6-digit OTP code.";
                    return;
                }

                errorText.text = "";
                console.log("TODO AuthController.verifyEmail", root.otpCode);
                root.confirmed();
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            spacing: 4

            Label {
                text: "Did not receive a code?"
                color: root.mutedColor
                font.pixelSize: 13
            }

            Label {
                text: "Resend"
                color: root.primaryColor
                font.pixelSize: 13
                font.bold: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("TODO AuthController resend email OTP", root.email);
                        root.resendRequested();
                    }
                }
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
                text: "Do not share the OTP code."
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
