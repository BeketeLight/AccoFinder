import QtQuick

Item {
    id: root

    // Real data is sourced from the C++ AdminNotificationsViewModel
    // (AdminNotificationsRepository -> /api/notifications API). Send goes
    // through POST /announce and history is loaded from GET /announcements,
    // so no value is hard-coded. History returned from the API is one doc per
    // recipient, so rows are aggregated by title (summing the delivered count)
    // to show one announcement per send.
    readonly property alias notificationsModel: notificationsModelId

    function audienceCode(label) {
        switch (label) {
        case "All users": return "ALL"
        case "Clients": return "CLIENT"
        case "Agents": return "AGENT"
        }
        return "ALL"
    }

    function audienceLabel(code) {
        switch (code) {
        case "ALL": return "All users"
        case "CLIENT": return "Clients"
        case "AGENT": return "Agents"
        case "ADMIN": return "Admins"
        }
        return "All users"
    }

    function formatDate(value) {
        if (value === undefined || value === null || value === "")
            return "—"
        return Qt.formatDate(new Date(value), "d MMM yyyy")
    }

    function sendAnnouncement(title, message, audience) {
        AdminNotificationsViewModel.sendAnnouncement(audienceCode(audience), title, message)
        // Refresh the shared notification list shortly after the announce is
        // sent so the bell badge reflects any notification the admin themselves
        // received (e.g. when the audience is "All users"). A recurring poll in
        // Main.qml is the second safety net if this races the backend write.
        Qt.callLater(function() {
            NotificationViewModel.getNotifications()
        })
    }

    function reload() {
        notificationsModelId.clear()
        var agg = ({})
        var vm = AdminNotificationsViewModel.notificationsModel
        for (var i = 0; i < vm.size(); i++) {
            var row = vm.at(i)
            var title = row.title
            if (!agg.hasOwnProperty(title)) {
                agg[title] = {
                    title: title,
                    message: row.message,
                    audience: audienceLabel(row.recipientRole),
                    date: formatDate(row.createdAt),
                    delivered: 0
                }
            }
            agg[title].delivered++
        }
        for (var key in agg)
            notificationsModelId.append(agg[key])
    }

    ListModel {
        id: notificationsModelId
    }

    Connections {
        target: AdminNotificationsViewModel.notificationsModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Component.onCompleted: {
        root.reload()
        AdminNotificationsViewModel.refresh()
    }
}