import QtQuick

Item {
    id: root

    // Delegate-facing API preserved. Real data sourced from the C++
    // DisputesListViewModel (DisputeController -> /disputes/ API).
    readonly property alias disputesModel: disputesModelId
    readonly property alias viewModel: viewModelId

    property string statusFilter: "ALL"   // ALL | Open | In review | Resolved | Rejected

    property int openCount: 0
    property int inReviewCount: 0
    property int resolvedCount: 0

    function refresh() {
        var open = 0, review = 0, resolved = 0
        for (var i = 0; i < disputesModelId.count; i++) {
            var s = disputesModelId.get(i).status
            if (s === "Open") open++
            else if (s === "In review") review++
            else if (s === "Resolved") resolved++
        }
        root.openCount = open
        root.inReviewCount = review
        root.resolvedCount = resolved
        applyFilters()
    }

    function applyFilters() {
        viewModelId.clear()
        for (var i = 0; i < disputesModelId.count; i++) {
            var d = disputesModelId.get(i)
            if (root.statusFilter !== "ALL" && d.status !== root.statusFilter)
                continue
            viewModelId.append({
                disputeId: d.disputeId, subject: d.subject, property: d.property,
                client: d.client, opened: d.opened, status: d.status,
                detail: d.detail
            })
        }
    }

    function findDispute(disputeId) {
        for (var i = 0; i < disputesModelId.count; i++) {
            var d = disputesModelId.get(i)
            if (d.disputeId === disputeId)
                return { disputeId: d.disputeId, subject: d.subject, property: d.property,
                         client: d.client, opened: d.opened, status: d.status, detail: d.detail }
        }
        return null
    }

    function setStatus(disputeId, status) {
        // Optimistically reflect the new status locally, then persist via the
        // real API when the server confirms the change.
        for (var r = 0; r < disputesModelId.count; r++) {
            var d = disputesModelId.get(r)
            if (d.disputeId === disputeId) {
                d.status = status
                disputesModelId.set(r, d)
                break
            }
        }
        var cppModel = DisputesListViewModel.disputesListModel
        var idx = -1
        if (cppModel) {
            var n = cppModel.size()
            for (var i = 0; i < n; i++) {
                if (cppModel.at(i).id === disputeId) {
                    idx = i
                    break
                }
            }
        }
        if (idx >= 0)
            DisputesListViewModel.resolveDispute(idx, disputeId, status)
        refresh()
    }

    function mapStatus(raw) {
        if (raw.toLowerCase() === "open") return "Open"
        if (raw.toLowerCase() === "resolved") return "Resolved"
        if (raw.toLowerCase() === "in review") return "In review"
        if (raw.toLowerCase() === "rejected") return "Rejected"
        return "Open"
    }

    ListModel {
        id: disputesModelId
    }

    ListModel {
        id: viewModelId
    }

    function reload() {
        disputesModelId.clear()
        var m = DisputesListViewModel.disputesListModel
        var cppSize = m ? m.size() : 0
        for (var i = 0; i < cppSize; i++) {
            var item = m.at(i)
            disputesModelId.append({
                disputeId: item.id, subject: item.issue,
                property: item.bookingId.length > 0 ? "Booking " + item.bookingId : "",
                client: "", opened: "", status: root.mapStatus(item.status),
                detail: item.issue
            })
        }
        root.refresh()
    }

    Connections {
        target: DisputesListViewModel.disputesListModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Component.onCompleted: {
        DisputesListViewModel.getDisputes()
    }
}
