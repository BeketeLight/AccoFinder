import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string notificationId: ""
    property string title: ""
    property string message: ""
    property bool unread: false
    property bool showSeparator: true

    property color primaryColor: "#2563EB"
    property color softBlueColor: "#EFF6FF"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: notifRow.implicitHeight + 20
        color: root.unread ? root.softBlueColor : "transparent"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.unread) {
                    NotificationViewModel.markRead(root.notificationId)
                    // Give the backend a beat to persist, then pull the fresh
                    // list so the badge and rows update.
                    Qt.callLater(function() {
                        NotificationViewModel.refreshCurrent()
                    })
                }
            }
        }

        RowLayout {
            id: notifRow
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: root.unread ? root.primaryColor : "transparent"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    Layout.fillWidth: true
                    text: root.title
                    color: root.textColor
                    font.pixelSize: 13
                    font.bold: root.unread
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: root.message
                    color: root.mutedColor
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
        }
    }

    Rectangle {
        visible: root.showSeparator
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: root.borderColor
    }
}