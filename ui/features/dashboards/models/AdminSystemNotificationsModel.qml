import QtQuick

Item {
    id: root

    // Delegate-facing API preserved. Announcements are kept locally for the
    // current session; no backend history endpoint exists, so sent history
    // starts empty and shows its empty-state message.
    readonly property alias notificationsModel: notificationsModelId

    function sendAnnouncement(title, message, audience) {
        // Newest first
        notificationsModelId.insert(0, {
            title: title,
            message: message,
            audience: audience,
            date: Qt.formatDate(new Date(), "d MMM yyyy"),
            delivered: 0
        })
    }

    ListModel {
        id: notificationsModelId
    }
}
