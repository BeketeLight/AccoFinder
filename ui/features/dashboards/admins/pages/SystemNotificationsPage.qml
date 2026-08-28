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
    property int maxMessageChars: 500

    signal announcementSent(var payload)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color surfaceColor: "#F5F5F5"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"
    readonly property color errorColor: "#DC2626"

    function send() {
        titleError.visible = false
        messageError.visible = false

        var valid = true
        if (titleInput.text.trim().length < 3) {
            titleError.visible = true
            valid = false
        }
        if (messageArea.text.trim().length < 10) {
            messageError.visible = true
            valid = false
        }
        if (!valid)
            return

        var payload = {
            title: titleInput.text.trim(),
            message: messageArea.text.trim(),
            audience: audienceDropdown.currentText,
            date: Qt.formatDate(new Date(), "d MMM yyyy"),
            delivered: 0
        }

        notificationsModel.sendAnnouncement(payload.title, payload.message, payload.audience)
        console.log("Announcement sent:", JSON.stringify(payload))
        root.announcementSent(payload)

        sentBanner.visible = true
        sentTimer.restart()

        titleInput.text = ""
        messageArea.text = ""
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

                AppTextInput {
                    id: titleInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    label: qsTr("Title")
                    placeholder: qsTr("e.g. Scheduled maintenance")
                    required: true
                    fieldHeight: 52
                    backgroundColor: root.surfaceColor
                    textColor: root.textColor
                    labelColor: root.textColor
                    placeholderColor: "#9CA3AF"
                    borderColor: root.borderColor
                    focusColor: root.primaryColor
                    errorColor: root.errorColor
                }

                Label {
                    id: titleError
                    visible: false
                    text: qsTr("Give the announcement a title")
                    color: root.errorColor
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: qsTr("Message *")
                        color: root.textColor
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }

                    TextArea {
                        id: messageArea
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(Math.max(messageArea.contentHeight + 36, 110), 220)
                        color: root.textColor
                        font.pixelSize: 14
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                        leftPadding: 14
                        rightPadding: 14
                        topPadding: messageArea.activeFocus || messageArea.text.length > 0 ? 30 : 14
                        bottomPadding: 10

                        property int maxLength: root.maxMessageChars

                        onTextChanged: {
                            if (text.length > maxLength) {
                                var cursorPos = cursorPosition
                                text = text.substring(0, maxLength)
                                cursorPosition = Math.min(cursorPos, text.length)
                            }
                        }

                        background: Item {
                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: root.surfaceColor
                                border.width: messageArea.activeFocus || messageError.visible ? 2 : 1
                                border.color: messageError.visible ? root.errorColor
                                             : messageArea.activeFocus ? root.primaryColor
                                             : root.borderColor
                            }

                            Label {
                                id: messageFloating
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                anchors.topMargin: 8
                                readonly property bool isFloating: messageArea.activeFocus || messageArea.text.length > 0
                                text: qsTr("Write your announcement\u2026")
                                color: messageError.visible ? root.errorColor
                                       : messageArea.activeFocus ? root.primaryColor
                                       : "#9CA3AF"
                                font.pixelSize: isFloating ? 11 : 14
                                font.weight: isFloating ? Font.Medium : Font.Normal
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                height: isFloating ? 18 : parent.height

                                Behavior on font.pixelSize {
                                    NumberAnimation {
                                        duration: 140
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 140
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            id: messageCount
                            Layout.alignment: Qt.AlignRight
                            text: qsTr("%L1 / %L2 characters").arg(messageArea.length).arg(root.maxMessageChars)
                            color: messageArea.length >= root.maxMessageChars ? root.errorColor : "#9CA3AF"
                            font.pixelSize: 11
                        }
                    }
                }

                Label {
                    id: messageError
                    visible: false
                    text: qsTr("Write at least a sentence")
                    color: root.errorColor
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    AppDropdown {
                        id: audienceDropdown
                        Layout.fillWidth: true
                        Layout.preferredHeight: 76
                        fieldHeight: 52
                        label: qsTr("Audience")
                        placeholder: qsTr("Select audience")
                        model: ["All users", "Clients", "Agents"]
                        backgroundColor: root.surfaceColor
                        borderColor: root.borderColor
                        focusBorderColor: root.primaryColor
                        textColor: root.textColor
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
                        text: historyRow.model.date + " \u00B7 " + qsTr("delivered to %1 users").arg(historyRow.model.delivered)
                        color: "#9CA3AF"
                        font.pixelSize: 10
                    }
                }
            }
        }

        Label {
            visible: root.notificationsModel.notificationsModel.count === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No announcements sent yet.")
            color: root.mutedColor
            font.pixelSize: 12
            topPadding: 8
        }
    }

    Timer {
        id: sentTimer
        interval: 4000
        onTriggered: sentBanner.visible = false
    }
}
