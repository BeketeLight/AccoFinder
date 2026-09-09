import QtQuick
import QtQuick.Controls
import "../../utils/NavigationUtils.js" as NavUtils

// A notification bell with an unread-count badge. Intended to be used as the
// header right-component action (see AppHeader.rightAction) across dashboards
// and any screen that should surface the account-level notification list.
Item {
    id: root

    // Path to the notifications screen (URL or qrc string). On click the bell
    // emits activated() then navigates here if a path is provided.
    property url notificationScreen: ""
    // Unread count; defaults to the shared NotificationViewModel's model.
    property int unreadCount: NotificationViewModel.notificationListModel.unreadCount
    property color badgeColor: "#DC2626"
    property color iconColor: "#1F2937"
    signal activated()

    implicitWidth: 36
    implicitHeight: 36

    ToolButton {
        anchors.centerIn: parent
        icon.color: root.iconColor
        icon.height: 24
        icon.width: 24
        icon.source: "qrc:/ui/assets/notification.svg"
        onClicked: {
            root.activated()
            if (root.notificationScreen.toString().length > 0)
                NavUtils.push(Qt.resolvedUrl(root.notificationScreen))
        }
    }

    Rectangle {
        visible: root.unreadCount > 0
        width: 16
        height: 16
        radius: 8
        anchors.top: parent.top
        anchors.right: parent.right
        color: root.badgeColor
        border.color: "#FFFFFF"
        border.width: 1

        Label {
            anchors.centerIn: parent
            text: root.unreadCount > 99 ? "99+" : String(root.unreadCount)
            color: "#FFFFFF"
            font.pixelSize: 9
            font.bold: true
        }
    }
}
