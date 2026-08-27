import QtQuick 2.15

Item {
    id: root

    property string agentName: AppSettings.isLoggedIn() && AppSettings.userName().length > 0 ? AppSettings.userName() : "Agent"
    property double commissionRate: AppSettings.commissionRate()

    property int totalProperties: 6
    property int pendingVerifications: 2
    property int verifiedProperties: 2
    property int availableRooms: 37
    property int bookedRooms: 21
    property int pendingBookings: 1
    property int confirmedBookings: 2
    property int cancelledBookings: 1
    property real totalBookingValue: 109000
    property real commissionEarned: 8720

    readonly property alias attentionModel: attentionModelId
    // Live C++ list models. These are populated by their owning view models
    // (BookingViewModel / NotificationViewModel / DisputesListViewModel). The
    // delegates stay unchanged; the fake ListModel data has been removed.
    readonly property var recentBookingsModel: BookingViewModel.bookingListModel
    readonly property var notificationsModel: NotificationViewModel.notificationListModel
    readonly property var disputesModel: DisputesListViewModel.disputesListModel

    ListModel {
        id: attentionModelId
    }

    function refreshAttention() {
        attentionModelId.clear()

        // Server-backed properties that need the agent's action. Detection is
        // limited to the fields exposed by propertiesForView(): status + price.
        var server = PropertyViewModel.propertiesForView() || []
        for (var s = 0; s < server.length; s++) {
            var sp = server[s] || {}
            var status = String(sp.verificationStatus || "").toUpperCase()
            if (status === "REJECTED") {
                attentionModelId.append({
                    title: sp.title || "Untitled property",
                    reason: qsTr("Verification rejected — resubmit"),
                    actionLabel: qsTr("Resubmit"),
                    kind: "server",
                    targetId: String(sp.id || "")
                })
            } else if (status !== "VERIFIED" && (sp.price === undefined || Number(sp.price) <= 0)) {
                attentionModelId.append({
                    title: sp.title || "Untitled property",
                    reason: qsTr("Missing or to-be-negotiated price — add pricing"),
                    actionLabel: qsTr("Update"),
                    kind: "server",
                    targetId: String(sp.id || "")
                })
            }
        }

        // Local drafts never hit the backend (failed uploads needing review).
        var drafts = DraftViewModel.allDrafts() || {}
        var keys = Object.keys(drafts)
        for (var i = 0; i < keys.length; i++) {
            var d = drafts[keys[i]] || {}
            var title = d.title || "Untitled property"
            var reason = qsTr("Draft failed to upload — review and resend")
            attentionModelId.append({
                title: title,
                reason: reason,
                actionLabel: qsTr("Review"),
                kind: "draft",
                targetId: keys[i]
            })
        }
    }

    // Pull data for all dashboard sections from their C++ view models.
    function refreshAll() {
        root.refreshAttention()
        BookingViewModel.fetchBookings()
        NotificationViewModel.getNotifications()
        DisputesListViewModel.getDisputes()
    }

    Component.onCompleted: {
        root.refreshAll()
    }

    Connections {
        target: DraftViewModel
        function onDraftsChanged() { root.refreshAttention() }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onModelReset() { root.refreshAttention() }
        function onRowsInserted(parent, first, last) { root.refreshAttention() }
    }
}
