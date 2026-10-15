import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: userCard
    property string cardTitle: "Client Info"
    property string cardIcon: "qrc:/ui/assets/account-icon.svg"
    property string  emailIcon: ""
    property string userEmail: "@"
    property string userName: "Unknown"
    property string userPhone: ""
    property string userInitial: "D"
    property string userAvatar: "" // if image path
    property int custIconHeight: 12
    property int custIconWidth: 12

    Layout.fillWidth: true
    implicitHeight: hostRow.implicitHeight + 52
    radius: 12
    border.color: "#E2E8F0"
    border.width: 1
    color: "#FFFFFF"
    ColumnLayout {
        id: hostCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 8
        RowLayout {
            spacing: 8
            RowLayout {
                spacing: 0
                ToolButton {
                    icon.source: userCard.cardIcon
                    icon.height: userCard.custIconHeight
                    icon.width: userCard.custIconWidth
                    background: null
                }
                Text {
                    text: userCard.cardTitle
                    font.pixelSize: 14
                    font.bold: true
                    color: "#0F172A"
                }
            }
        }

        // Body Content Row
        RowLayout {
            id: hostRow
            Layout.fillWidth: true
            spacing: 12

            // Avatar / Initial Circle
            Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: "#E2E8F0"
                clip: true

                // Show image if userAvatar is provided, otherwise show initials
                Image {
                    anchors.fill: parent
                    source: userCard.userAvatar
                    fillMode: Image.PreserveAspectCrop
                    visible: userCard.userAvatar !== ""
                }

                Text {
                    anchors.centerIn: parent
                    text: userCard.userInitial
                    color: "#2563EB"
                    font.pointSize: 14
                    font.bold: true
                    visible: userCard.userAvatar === ""
                }
            }

            // Name, Phone Number, and Call Button
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: userCard.userName
                        font.pixelSize: 13
                        font.bold: true
                        color: "#0F172A"
                    }
                    Text {
                        text: userCard.userPhone
                        font.pixelSize: 11
                        color: "#64748B"
                    }
                    RowLayout{
                        spacing: 0
                        visible: userCard.userEmail !== ""
                        ToolButton{
                            icon.source: userCard.emailIcon
                            icon.height: 14
                            icon.width: 14
                            background: null
                        }
                        Text {
                            text: userCard.userEmail
                            font.pixelSize: 11
                            color: "#64748B"
                        }
                    }
                }
               Item{Layout.fillWidth: true}
                // Call Button
                Button {
                    id: callButton
                    text: "Call"
                    font.pixelSize: 12
                    font.bold: true
                    implicitHeight: 32
                    implicitWidth: 70
                    visible: userCard.userPhone

                    contentItem: Text {
                        text: callButton.text
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.bold: true
                    }

                    background: Rectangle {
                        color: callButton.pressed ? "#1D4ED8" : "#2563EB"
                        radius: 16
                    }

                    onClicked: {
                        console.log("[Call] Opening dialer for:", userCard.userPhone)
                        var phoneNum = userCard.userPhone.toString().trim()
                        Qt.openUrlExternally("tel:" + phoneNum)
                    }
                }
            }
        }
    }
}