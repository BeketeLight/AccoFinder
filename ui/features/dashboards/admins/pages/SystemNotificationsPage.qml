import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../../components/inputs"
import "../../models"

Item {
    id: root

    property AdminSystemNotificationsModel notificationsModel: AdminSystemNotificationsModel {}
    property string pageTitle: qsTr("Announcements")

    signal announcementSent(var payload)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    function send() {
        titleError.text = ""
        messageError.text = ""

        var valid = true
        if (titleInput.text.trim().length < 3) {
            titleError.text = qsTr("Give the announcement a title")
            valid = false
        }
        if (messageInput.text.trim().length < 10) {
            messageError.text = qsTr("Write at least a sentence")
            valid = false
        }
        if (!valid)
            return

        var payload = {
            title: titleInput.text.trim(),
            message: messageInput.text.trim(),
            audience: audienceDropdown.currentText,
            date: Qt.formatDate(new Date(), "d MMM yyyy"),
            delivered: 0
        }

        notificationsModel.sendAnnouncement(payload.title, payload.message, payload.audience)
        console.log("Announcement sent:", JSON.stringify(payload))
        root.announcementSent(payload)

        sentBanner.visible = true
        sentTimer.restart()

        titleInput.clear()
        messageInput.clear()
        audienceDropdown.currentIndex = -1
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Send announcement")
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: composeColumn.implicitHeight + 28
            radius: 12
            color: "#FFFFFF"
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: composeColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label { text: qsTr("Title"); font.pixelSize: 12; font.bold: true; color: root.textColor }

                    TextField {
                        id: titleInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        placeholderText: qsTr("e.g. Scheduled maintenance")
                        font.pixelSize: 13
                        color: root.textColor
                        background: Rectangle {
                            radius: 8
                            border.color: titleInput.activeFocus ? root.primaryColor : "#E5E7EB"
                            border.width: 1
                        }
                    }

                    Label { id: titleError; visible: text.length > 0; text: ""; color: "#DC2626"; font.pixelSize: 11 }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label { text: qsTr("Message"); font.pixelSize: 12; font.bold: true; color: root.textColor }

                    TextArea {
                        id: messageInput
                        Layout.fillWidth: true
                        implicitHeight: Math.max(88, contentHeight + 20)
                        placeholderText: qsTr("Write your announcement…")
                        font.pixelSize: 13
                        color: root.textColor
                        wrapMode: TextEdit.WordWrap
                        background: Rectangle {
                            radius: 8
                            border.color: messageInput.activeFocus ? root.primaryColor : "#E5E7EB"
                            border.width: 1
                        }
                    }

                    Label { id: messageError; visible: text.length > 0; text: ""; color: "#DC2626"; font.pixelSize: 11 }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label { text: qsTr("Audience"); font.pixelSize: 12; font.bold: true; color: root.textColor }

                    AppDropdown {
                        id: audienceDropdown
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        placeholder: qsTr("Select audience")
                        model: ["All users", "Clients", "Agents", "Landlords"]
                    }
                }

                Button {
                    id: sendButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: qsTr("Send announcement")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: sendButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 10
                        color: sendButton.down ? "#1D4ED8" : root.primaryColor
                    }

                    onClicked: root.send()
                }
            }
        }

        Rectangle {
            id: sentBanner
            visible: false
            Layout.fillWidth: true
            implicitHeight: 44
            radius: 12
            color: "#ECFDF5"
            border.color: "#BBF7D0"
            border.width: 1

            Label {
                anchors.centerIn: parent
                text: qsTr("Announcement delivered.")
                color: "#166534"
                font.pixelSize: 12
                font.bold: true
            }
        }

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Sent history")
        }

        Repeater {
            model: root.notificationsModel.notificationsModel

            delegate: Rectangle {
                id: historyRow
                required property var model
                required property int index
                Layout.fillWidth: true
                implicitHeight: historyContent.implicitHeight + 20
                radius: 12
                color: "#FFFFFF"
                border.color: root.borderColor
                border.width: 1

                ColumnLayout {
                    id: historyContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            Layout.fillWidth: true
                            text: historyRow.model.title
                            color: "#111827"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            implicitHeight: 20
                            implicitWidth: audienceLabel.implicitWidth + 14
                            radius: 10
                            color: "#EFF6FF"

                            Label {
                                id: audienceLabel
                                anchors.centerIn: parent
                                text: historyRow.model.audience
                                color: root.primaryColor
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: historyRow.model.message
                        color: root.mutedColor
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        Layout.fillWidth: true
                        text: historyRow.model.date + " · " + qsTr("delivered to %1 users").arg(historyRow.model.delivered)
                        color: "#9CA3AF"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }

    Timer {
        id: sentTimer
        interval: 4000
        onTriggered: sentBanner.visible = false
    }
}
