import QtQuick 2.15

Item {
    id: root

    property string agentName: AppSettings.isLoggedIn() && AppSettings.userName().length > 0 ? AppSettings.userName() : "Agent"
    // Commission rate defaults to 10% for agents when the backend hasn't set a
    // value yet, so the hero never shows a confusing 0%. refreshTick makes the
    // binding re-read AppSettings when the rate is fetched/updated mid-session.
    property double commissionRate: (AppSettings.commissionRate() > 0 ? AppSettings.commissionRate() : 10) + refreshTick - refreshTick
    // The agent's work area is the location they provided at signup (we never
    // assign an area to an agent), stored in residentialAddress. refreshTick
    // makes this re-read AppSettings after the profile fetch completes.
    property string agentArea: (AppSettings.preferredLocation() || AppSettings.assignedArea() || "") + (refreshTick - refreshTick === 0 ? "" : "")

    // Real stats computed from the live C++ view models. When there is no data
    // yet these fall back to zero — no fake numbers are ever shown on cards.
    // Each depends on refreshTick so they re-evaluate whenever the underlying
    // view models signal that fresh data has arrived.
    property int refreshTick: 0

    // The dashboard is the current user's own view, so every property stat is
    // computed from the rows belonging to this user (matched by the parsed
    // owner/agentId). The shared C++ PropertyViewModel can hold everyone's
    // listings, so counting it directly would leak other agents' numbers here.
    function myProperties() {
        var myId = String(AppSettings.userId())
        var out = []
        var server = PropertyViewModel.propertiesForView() || []
        for (var s = 0; s < server.length; s++) {
            var sp = server[s] || {}
            var ownerId = String(sp.agentId || "")
            if (ownerId.length > 0 && ownerId !== myId)
                continue
            out.push(sp)
        }
        return out
    }

    property int totalProperties: root.myProperties().length + refreshTick - refreshTick
    property int pendingVerifications: root.countPending(root.myProperties()) + refreshTick - refreshTick
    property int verifiedProperties: root.countVerified(root.myProperties()) + refreshTick - refreshTick

    function countPending(list) {
        var n = 0
        for (var i = 0; i < list.length; i++) {
            var status = String(list[i].verificationStatus || "").toUpperCase()
            if (status !== "VERIFIED" && status !== "REJECTED")
                n++
        }
        return n
    }
    function countVerified(list) {
        var n = 0
        for (var i = 0; i < list.length; i++) {
            if (String(list[i].verificationStatus || "").toUpperCase() === "VERIFIED")
                n++
        }
        return n
    }

    // Rooms are scoped to the current user too: only rooms belonging to the
    // user's own properties (matched by property id against myProperties()) are
    // counted. The shared C++ room model holds every agent's rooms, so counting
    // it directly would leak other agents' rooms onto this dashboard.
    function myRooms() {
        var rooms = []
        var props = root.myProperties()
        for (var p = 0; p < props.length; p++) {
            var pid = String(props[p].id || "")
            if (!pid)
                continue
            var rs = RoomViewModel.roomsForProperty(pid) || []
            for (var r = 0; r < rs.length; r++)
                rooms.push(rs[r])
        }
        return rooms
    }
    function countRoomState(list, available) {
        var n = 0
        for (var i = 0; i < list.length; i++) {
            if (String(list[i].available) === available)
                n++
        }
        return n
    }
    property int availableRooms: root.countRoomState(root.myRooms(), "true") + refreshTick - refreshTick
    property int bookedRooms: root.countRoomState(root.myRooms(), "false") + refreshTick - refreshTick

    // Bookings and disputes are scoped the same way: a booking only counts if
    // its room belongs to one of the current user's own properties (resolved
    // roomId -> propertyId -> owner). Without this the counts and lists include
    // bookings made on other agents' rooms.
    function propertyIdsOwned() {
        var myId = String(AppSettings.userId())
        var ids = []
        var server = PropertyViewModel.propertiesForView() || []
        for (var s = 0; s < server.length; s++) {
            var sp = server[s] || {}
            var ownerId = String(sp.agentId || "")
            if (ownerId.length > 0 && ownerId !== myId)
                continue
            ids.push(String(sp.id || ""))
        }
        return ids
    }
    function roomBelongsToMe(roomId) {
        if (!roomId)
            return false
        var owned = root.propertyIdsOwned()
        var rm = RoomViewModel.roomListModel
        if (!rm)
            return false
        for (var i = 0; i < rm.count; i++) {
            var row = rm.get(i)
            if (String(row.id) === String(roomId) && owned.indexOf(String(row.propertyId)) !== -1)
                return true
        }
        return false
    }
    function myBookings() {
        var out = []
        var bm = BookingViewModel.bookingListModel
        if (!bm)
            return out
        for (var i = 0; i < bm.count; i++) {
            var b = bm.get(i)
            if (root.roomBelongsToMe(b.roomId))
                out.push(b)
        }
        return out
    }
    function countBookingStatus(list, statuses) {
        var n = 0
        for (var i = 0; i < list.length; i++) {
            var st = String(list[i].status || "").toLowerCase()
            if (statuses.indexOf(st) !== -1)
                n++
        }
        return n
    }
    function sumBookingField(list, field) {
        var total = 0
        for (var i = 0; i < list.length; i++)
            total += Number(list[i][field] || 0)
        return total
    }
    property int pendingBookings: root.countBookingStatus(root.myBookings(), ["pending"]) + refreshTick - refreshTick
    property int confirmedBookings: root.countBookingStatus(root.myBookings(), ["confirmed", "paid"]) + refreshTick - refreshTick
    property int cancelledBookings: root.countBookingStatus(root.myBookings(), ["cancelled"]) + refreshTick - refreshTick
    property real totalBookingValue: root.sumBookingField(root.myBookings(), "amount") + refreshTick - refreshTick
    property real commissionEarned: root.sumBookingField(root.myBookings(), "commissionAmount") + refreshTick - refreshTick

    readonly property alias attentionModel: attentionModelId
    // Live C++ list models. These are populated by their owning view models
    // (BookingViewModel / NotificationViewModel / DisputesListViewModel). The
    // recent bookings list is owner-scoped; notifications and disputes remain
    // as-is (notifications are account-level; disputes are tenant-raised).
    readonly property var recentBookingsModel: myBookingsModelId
    readonly property var notificationsModel: NotificationViewModel.notificationListModel
    readonly property var disputesModel: myDisputesModelId

    ListModel {
        id: attentionModelId
    }

    // Owner-scoped copy of the recent bookings list (only bookings on the
    // current user's own rooms).
    ListModel {
        id: myBookingsModelId
    }

    // Owner-scoped copy of the open disputes list (only disputes on the
    // current user's own bookings/rooms).
    ListModel {
        id: myDisputesModelId
    }

    function refreshMyBookings() {
        myBookingsModelId.clear()
        var rows = root.myBookings()
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i]
            myBookingsModelId.append({
                bookingId: r.bookingId || "",
                roomId: r.roomId || "",
                bookingDate: r.bookingDate || "",
                amount: Number(r.amount || 0),
                status: r.status || "Pending"
            })
        }
    }

    function bookingBelongsToMe(bookingId) {
        if (!bookingId)
            return false
        var bm = BookingViewModel.bookingListModel
        if (!bm)
            return false
        for (var i = 0; i < bm.count; i++) {
            var b = bm.get(i)
            if (String(b.bookingId) === String(bookingId))
                return root.roomBelongsToMe(b.roomId)
        }
        return false
    }

    function refreshMyDisputes() {
        myDisputesModelId.clear()
        var dm = DisputesListViewModel.disputesListModel
        if (!dm)
            return
        for (var i = 0; i < dm.count; i++) {
            var d = dm.get(i)
            if (!root.bookingBelongsToMe(d.bookingId))
                continue
            myDisputesModelId.append({
                id: d.id || "",
                bookingId: d.bookingId || "",
                issue: d.issue || "",
                status: d.status || "Open"
            })
        }
    }

    function refreshAttention() {
        attentionModelId.clear()

        // Only surface the current user's own listings. The shared
        // PropertyViewModel can be refreshed by other screens with the full
        // list, so filter here too by the parsed owner/agentId — otherwise
        // another agent's rejected / missing-price property would appear here.
        var myId = AppSettings.userId()

        // Server-backed properties that need the agent's action. Detection is
        // limited to the fields exposed by propertiesForView(): status + price.
        var server = PropertyViewModel.propertiesForView() || []
        for (var s = 0; s < server.length; s++) {
            var sp = server[s] || {}
            var ownerId = String(sp.agentId || "")
            if (ownerId.length > 0 && ownerId !== String(myId))
                continue
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
        root.refreshMyBookings()
        root.refreshMyDisputes()
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

    // Data is fetched by the owning screen (AgentsDashboardScreen drives
    // refreshAll() on entry and on pull-to-refresh), so we don't auto-load here
    // to avoid a redundant duplicate backend call on every screen entry.

    Connections {
        target: AgentViewModel
        function onMyCommissionUpdated() { root.refreshStats() }
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
        function onModelReset() { root.refreshAttention(); root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
        function onRowsInserted(parent, first, last) { root.refreshAttention(); root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
        function onRowsRemoved(parent, first, last) { root.refreshAttention(); root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
    }

    Connections {
        target: BookingViewModel.bookingListModel
        function onCountChanged(newCount) { root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
        function onModelReset() { root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
    }

    Connections {
        target: RoomViewModel.roomListModel
        function onModelReset() { root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
        function onRowsInserted(parent, first, last) { root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
        function onRowsRemoved(parent, first, last) { root.refreshMyBookings(); root.refreshMyDisputes(); root.refreshStats() }
    }

    Connections {
        target: DisputesListViewModel.disputesListModel
        function onCountChanged(newCount) { root.refreshMyDisputes(); root.refreshStats() }
        function onModelReset() { root.refreshMyDisputes(); root.refreshStats() }
    }
}
