import QtQuick

// QML-side filter over the shared C++ BookingListModel, following the same
// pattern as AdminUsersModel: the real rows always come from
// BookingViewModel.bookingListModel, and only the status-filtered projection
// lives in a QML ListModel so the Repeater can stay non-virtualised inside the
// scrollable page.
Item {
    id: root

    property string statusFilter: "ALL"   // ALL | PENDING | CONFIRMED | CANCELLED

    // Booking id of the row currently waiting on a confirm/cancel call, so only
    // the affected card shows an inline spinner.
    property string busyBookingId: ""

    readonly property int pendingCount: countFor("Pending")
    readonly property int confirmedCount: countFor("Confirmed") + countFor("Paid")
    readonly property int cancelledCount: countFor("Cancelled")
    readonly property int shownCount: viewModelId.count
    // Every booking the backend returned, before the status filter narrows it.
    readonly property int totalCount: sourceModel.count

    // Public handle on the status-filtered projection, so the page can bind a
    // Repeater's model to it. The name matches the sourceModel convention.
    readonly property alias viewModel: viewModelId

    function countFor(status) {
        var n = 0
        for (var i = 0; i < viewModelId.count; i++) {
            if (viewModelId.get(i).status === status)
                n++
        }
        return n
    }

    function statusMatches(status) {
        if (root.statusFilter === "ALL")
            return true
        if (root.statusFilter === "CONFIRMED")
            return status === "Confirmed" || status === "Paid"
        return status === root.statusFilter
    }

    function applyFilters() {
        viewModelId.clear()
        for (var i = 0; i < sourceModel.count; i++) {
            var b = sourceModel.get(i)
            if (!root.statusMatches(b.status))
                continue
            viewModelId.append(b)
        }
    }

    // Copies the C++ model into a QML ListModel. Done through at() because a
    // QAbstractListModel cannot be indexed from QML directly.
    function reload() {
        sourceModel.clear()
        var m = BookingViewModel.bookingListModel
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

    ListModel { id: sourceModel }
    ListModel { id: viewModelId }

    Connections {
        target: BookingViewModel.bookingListModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
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

    Component.onCompleted: root.reload()
}
