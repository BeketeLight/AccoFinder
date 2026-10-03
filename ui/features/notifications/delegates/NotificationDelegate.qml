import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/Utils.js" as Utils

ColumnLayout {
    id: root

    property string notificationId: ""
    property string title: ""
    property string message: ""
    property bool unread: false
    property bool showSeparator: true
    // When the notification was delivered. A Date (from the C++ role), an
    // ISO-8601 string, or epoch millis; empty when the backend never stamped it.
    property var createdAt: null

    // Empty when createdAt is unusable, so the row simply carries no timestamp
    // rather than implying the notification arrived in 1970.
    readonly property string timestamp: Utils.notificationTimestamp(root.createdAt)

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
            // Anchored on three sides only, never anchors.fill. The container
            // above takes its height from this row's implicitHeight, so filling
            // the parent here would be circular: the row would be pinned to a
            // height derived from itself, the wrapped message would be measured
            // before it had a real width, and any line beyond the first would be
            // clipped instead of the container growing to fit it.
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
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
                    // Subjects flow onto as many lines as they need. This label
                    // used to carry only elide: Text.ElideRight and no wrapMode,
                    // so under the default NoWrapping every subject was cut to a
                    // single line ending in an ellipsis and the rest was simply
                    // gone. wrapMode is what actually flows the text; elide is
                    // pinned to ElideNone so no line cap can creep back in.
                    wrapMode: Text.WordWrap
                    elide: Text.ElideNone
                }

                Label {
                    Layout.fillWidth: true
                    text: root.message
                    color: root.mutedColor
                    font.pixelSize: 11
                    lineHeight: 1.15
                    // The row is sized from the wrapped height, so the body flows
                    // onto as many lines as the text actually needs. No line cap
                    // and no elide: a truncated notification is a lost one.
                    wrapMode: Text.WordWrap
                    elide: Text.ElideNone
                }

                Label {
                    Layout.fillWidth: true
                    visible: root.timestamp.length > 0
                    text: root.timestamp
                    color: "#9CA3AF"
                    font.pixelSize: 10
                    // Trailing meta line: a fixed 24-hour clock and a short date
                    // never wrap, so it stays a single line under elide too.
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