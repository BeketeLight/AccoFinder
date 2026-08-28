import QtQuick 2.15

Item {
    id: root

    property string agentName: AppSettings.isLoggedIn() && AppSettings.userName().length > 0 ? AppSettings.userName() : "Agent"
    property double commissionRate: AppSettings.commissionRate()

    // Real stats computed from the live C++ view models. When there is no data
    // yet these fall back to zero — no fake numbers are ever shown on cards.
    // Each depends on refreshTick so they re-evaluate whenever the underlying
    // view models signal that fresh data has arrived.
    property int refreshTick: 0
    property int totalProperties: (PropertyViewModel.propertyListModel ? PropertyViewModel.propertyListModel.count : 0) + refreshTick - refreshTick
    property int pendingVerifications: PropertyViewModel.pendingPropertiesCount() + refreshTick - refreshTick
    property int verifiedProperties: PropertyViewModel.verifiedPropertiesCount() + refreshTick - refreshTick
    property int availableRooms: RoomViewModel.availableRoomsCount() + refreshTick - refreshTick
    property int bookedRooms: RoomViewModel.bookedRoomsCount() + refreshTick - refreshTick
    property int pendingBookings: BookingViewModel.pendingBookingsCount() + refreshTick - refreshTick
    property int confirmedBookings: BookingViewModel.confirmedBookingsCount() + refreshTick - refreshTick
    property int cancelledBookings: BookingViewModel.cancelledBookingsCount() + refreshTick - refreshTick
    property real totalBookingValue: BookingViewModel.totalBookingValue() + refreshTick - refreshTick
    property real commissionEarned: BookingViewModel.commissionEarned() + refreshTick - refreshTick

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
        PropertyViewModel.getProperties()
        RoomViewModel.loadRooms()
        BookingViewModel.fetchBookings()
        NotificationViewModel.getNotifications()
        DisputesListViewModel.getDisputes()
    }

    // Re-evaluate the stat bindings after fresh data has arrived.
    function refreshStats() {
        root.refreshTick = root.refreshTick + 1
    }

    Component.onCompleted: {
        root.refreshAll()
    }

    Connections {
        target: DraftViewModel
        function onDraftsChanged() { root.refreshAttention() }
    }

    Connections {
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshStats()
        }
    }

    Connections {
        target: RoomViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshStats()
        }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onModelReset() { root.refreshAttention(); root.refreshStats() }
        function onRowsInserted(parent, first, last) { root.refreshAttention(); root.refreshStats() }
        function onRowsRemoved(parent, first, last) { root.refreshAttention(); root.refreshStats() }
    }

    Connections {
        target: BookingViewModel.bookingListModel
        function onCountChanged(newCount) { root.refreshStats() }
        function onModelReset() { root.refreshStats() }
    }

    Connections {
        target: RoomViewModel.roomListModel
        function onModelReset() { root.refreshStats() }
        function onRowsInserted(parent, first, last) { root.refreshStats() }
        function onRowsRemoved(parent, first, last) { root.refreshStats() }
    }
}
