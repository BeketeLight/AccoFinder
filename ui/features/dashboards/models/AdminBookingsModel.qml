import QtQuick
import "../../../utils/Utils.js" as Utils

// QML-side filter over the shared C++ BookingListModel, following the same
// pattern as AdminUsersModel: the real rows always come from
// BookingViewModel.bookingListModel, and only the status-filtered projection
// lives in a QML ListModel so the Repeater can stay non-virtualised inside the
// scrollable page.
Item {
    id: root

    property string statusFilter: "ALL"   // ALL | PENDING | CONFIRMED | CANCELLED
    property string searchQuery: ""

    // Booking id of the row currently waiting on a confirm/cancel call, so only
    // the affected card shows an inline spinner.
    property string busyBookingId: ""

    // The admin bookings screen can be a cached root tab (via BookingPage) as
    // well as a pushed page. Wait until it is visible and idle before copying
    // the C++ rows into the QML mirrors.
    readonly property bool pageActive: Utils.isPageActive(root)
    property bool refreshAllowed: true
    readonly property bool canRebuild: root.pageActive && root.refreshAllowed
    property bool _reloadPending: false

    // Counters read sourceModel, never viewModelId: they describe the whole
    // booking list, so they must not collapse to whatever the active filter
    // happens to let through.
    readonly property int pendingCount: countInBucket("PENDING")
    readonly property int confirmedCount: countInBucket("CONFIRMED")
    readonly property int cancelledCount: countInBucket("CANCELLED")
    readonly property int shownCount: viewModelId.count
    // Every booking the backend returned, before the status filter narrows it.
    readonly property int totalCount: sourceModel.count

    // Public handle on the status-filtered projection, so the page can bind a
    // Repeater's model to it. The name matches the sourceModel convention.
    readonly property alias viewModel: viewModelId

    function countInBucket(bucket) {
        var n = 0
        for (var i = 0; i < sourceModel.count; i++) {
            if (Utils.bookingStatusBucket(sourceModel.get(i).status) === bucket)
                n++
        }
        return n
    }

    // Rows carry the display text BookingListModel renders ("Pending payment",
    // "Payment processing", ...), not the bare filter token, so the comparison
    // goes through the shared bucket rule instead of an equality check.
    function statusMatches(status) {
        if (root.statusFilter === "ALL")
            return true
        return Utils.bookingStatusBucket(status) === root.statusFilter
    }

    function searchMatches(b) {
        var q = String(root.searchQuery || "").trim().toLowerCase()
        if (q.length === 0)
            return true
        var fields = [
            b.clientName,
            b.clientEmail,
            b.clientPhone,
            b.bookingId,
            b.roomId
        ]
        for (var i = 0; i < fields.length; i++) {
            var v = String(fields[i] || "").toLowerCase()
            if (v.indexOf(q) !== -1)
                return true
        }
        return false
    }

    function applyFilters() {
        viewModelId.clear()
        for (var i = 0; i < sourceModel.count; i++) {
            var b = sourceModel.get(i)
            if (!root.statusMatches(b.status))
                continue
            if (!root.searchMatches(b))
                continue
            viewModelId.append(b)
        }
    }

    // Copies the C++ model into a QML ListModel. Done through at() because a
    // QAbstractListModel cannot be indexed from QML directly.
    function reload() {
        sourceModel.clear()
        var m = BookingViewModel ? BookingViewModel.bookingListModel : null
        if (!m)
            return
        for (var i = 0; i < m.count; i++) {
            var row = m.at(i)
            if (!row || row.bookingId === undefined)
                continue
            sourceModel.append(row)
        }
        root.applyFilters()
    }

    function requestReload() {
        root._reloadPending = true
        if (root.canRebuild && !reloadTimer.running)
            reloadTimer.start()
    }

    onCanRebuildChanged: {
        if (root.canRebuild && root._reloadPending && !reloadTimer.running)
            reloadTimer.start()
    }

    Timer {
        id: reloadTimer
        interval: 80
        repeat: true
        running: false
        onTriggered: {
            if (!root.canRebuild)
                return
            stop()
            root._reloadPending = false
            root.reload()
        }
    }

    ListModel { id: sourceModel }
    ListModel { id: viewModelId }

    Connections {
        enabled: root.pageActive
        target: BookingViewModel ? BookingViewModel.bookingListModel : null
        function onCountChanged() { root.requestReload() }
        function onDataChanged() { root.requestReload() }
        function onModelReset() { root.requestReload() }
    }

    Connections {
        target: BookingViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.busyBookingId = ""
        }
    }

    // Guard against a request that never reports back, so a single card cannot
    // stay permanently busy.
    Timer {
        id: busyGuard
        interval: 8000
        running: root.busyBookingId.length > 0
        onTriggered: root.busyBookingId = ""
    }

    Component.onCompleted: root.requestReload()
}
