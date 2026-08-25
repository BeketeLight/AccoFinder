import QtQuick

Item {
    id: root

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

        ListElement { title: "Scheduled maintenance"; message: "AccoFinder will be unavailable on Sunday 02:00–04:00 for maintenance."; audience: "All users"; date: "23 Aug 2026"; delivered: 1248 }
        ListElement { title: "New commission structure"; message: "Agent commissions now settle every Friday. Check your payout schedule."; audience: "Agents"; date: "21 Aug 2026"; delivered: 34 }
        ListElement { title: "Verification days"; message: "Listings verified within 48 hours this week get a boost in search results."; audience: "All users"; date: "18 Aug 2026"; delivered: 96 }
        ListElement { title: "Stay safe when booking"; message: "Never pay outside AccoFinder. Report suspicious listings via the app."; audience: "Clients"; date: "12 Aug 2026"; delivered: 1102 }
    }
}
