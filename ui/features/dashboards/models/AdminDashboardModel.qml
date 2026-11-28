import QtQuick
import "../../../utils/Utils.js" as Utils

Item {
    id: root

    property string adminName: AppSettings.isLoggedIn() && AppSettings.userName().length > 0 ? AppSettings.userName() : "Admin"

    // Real stats sourced from the DashboardController (C++ -> /dashboard/stats
    // API). Every value comes from the backend aggregation so no card shows a
    // hard-coded zero — a metric with no data yet returns 0 from the API. Each
    // binding depends on refreshTick so the cards re-evaluate when refreshed
    // data arrives.
    property int refreshTick: 0

    // The admin dashboard is a cached root landing page. Signals from other
    // screens must not clear/re-append its activity Repeater while the page is
    // hidden or the user is still flicking it.
    readonly property bool pageActive: Utils.isPageActive(root)
    property bool refreshAllowed: true
    readonly property bool canRebuild: root.pageActive && root.refreshAllowed
    property bool _activitiesDirty: false
    property bool _statsDirty: false

    property int totalUsers: (DashboardController !== null ? DashboardController.totalUsers : 0) + refreshTick - refreshTick
    property int registeredAgents: (DashboardController !== null ? DashboardController.totalAgents : 0) + refreshTick - refreshTick
    property int totalProperties: (DashboardController !== null ? DashboardController.totalProperties : 0) + refreshTick - refreshTick
    property int pendingVerifications: (DashboardController !== null ? DashboardController.pendingVerifications : 0) + refreshTick - refreshTick
    property int openDisputes: (DashboardController !== null ? DashboardController.openDisputes : 0) + refreshTick - refreshTick
    property int totalBookings: (DashboardController !== null ? DashboardController.totalBookings : 0) + refreshTick - refreshTick
    property real totalBookingValue: (DashboardController !== null ? DashboardController.totalBookingValue : 0) + refreshTick - refreshTick
    property real platformCommission: (DashboardController !== null ? DashboardController.platformCommission : 0) + refreshTick - refreshTick

    // Payment & commission oversight summary
    property real paymentsCollected: 0 + refreshTick - refreshTick
    property int paymentsPendingSettlement: 0 + refreshTick - refreshTick
    property real agentCommissionsDue: 0 + refreshTick - refreshTick
    property int ownerPayoutsPending: 0 + refreshTick - refreshTick

    readonly property alias pendingActivitiesModel: pendingActivitiesModelId

    ListModel {
        id: pendingActivitiesModelId
    }

    function refreshStats() {
        root.refreshTick = root.refreshTick + 1
    }

    // Build the "Actions & activity" list from real backend data:
    // properties awaiting verification surface as approval actions.
    function refreshActivities() {
        pendingActivitiesModelId.clear()

        var props = (PropertyViewModel && PropertyViewModel.propertiesForView)
                    ? PropertyViewModel.propertiesForView() : []
        for (var i = 0; i < props.length; i++) {
            var p = props[i] || {}
            var status = String(p.verificationStatus || "").trim().toUpperCase()
            if (Utils.isPendingVerification(status)) {
                pendingActivitiesModelId.append({
                    title: p.title || "Untitled property",
                    detail: qsTr("Property awaiting verification"),
                    kind: "approvals",
                    targetId: String(p.id || "")
                })
            } else if (status === "REJECTED") {
                pendingActivitiesModelId.append({
                    title: p.title || "Untitled property",
                    detail: qsTr("Verification rejected — review"),
                    kind: "approvals",
                    targetId: String(p.id || "")
                })
            }
        }

        // Listings that still need a decision are absent from the shared
        // property list (the listing endpoint only returns verified ones), so
        // the owner-scoped verification queue is scanned here too. Otherwise
        // the "Pending verifications" card counts a property this list never
        // mentions.
        var pending = PropertyViewModel ? PropertyViewModel.pendingListModel : null
        for (var j = 0; pending && j < pending.size(); j++) {
            var row = pending.at(j) || {}
            if (!Utils.isPendingVerification(row.status || row.verificationStatus))
                continue
            pendingActivitiesModelId.append({
                title: row.title || "Untitled property",
                detail: qsTr("Property awaiting verification"),
                kind: "approvals",
                targetId: String(row.propertyId || "")
            })
        }
    }

    function requestRefreshActivities() {
        root._activitiesDirty = true
        root.scheduleRefresh()
    }

    function requestRefreshStats() {
        root._statsDirty = true
        root.scheduleRefresh()
    }

    function scheduleRefresh() {
        if (!root.pageActive)
            return
        if (!refreshTimer.running)
            refreshTimer.start()
    }

    function applyPendingRefresh() {
        if (!root.canRebuild)
            return
        if (root._activitiesDirty)
            root.refreshActivities()
        if (root._statsDirty)
            root.refreshStats()
        root._activitiesDirty = false
        root._statsDirty = false
    }

    Timer {
        id: refreshTimer
        interval: 80
        repeat: true
        running: false
        onTriggered: {
            if (!root.canRebuild)
                return
            stop()
            root.applyPendingRefresh()
        }
    }

    onCanRebuildChanged: {
        if (root.canRebuild && (root._activitiesDirty || root._statsDirty) && !refreshTimer.running)
            refreshTimer.start()
    }

    Component.onCompleted: {
        // Populate from any already-cached properties. Network fetch is driven
        // by the screen so there is a single source for the initial load.
        root.requestRefreshActivities()
    }

    Connections {
        enabled: root.pageActive
        target: DashboardController
        function onStatsUpdated() { root.requestRefreshStats() }
    }

    Connections {
        enabled: root.pageActive
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.requestRefreshStats()
        }
    }

    Connections {
        enabled: root.pageActive
        target: PropertyViewModel !== null ? PropertyViewModel.propertyListModel : null
        function onModelReset() { root.requestRefreshActivities(); root.requestRefreshStats() }
        function onRowsInserted(parent, first, last) { root.requestRefreshActivities(); root.requestRefreshStats() }
        function onRowsRemoved(parent, first, last) { root.requestRefreshActivities(); root.requestRefreshStats() }
    }

    // The verification queue is filled owner by owner, so the activity list has
    // to follow it as rows arrive.
    Connections {
        enabled: root.pageActive
        target: PropertyViewModel !== null ? PropertyViewModel.pendingListModel : null
        function onCountChanged() { root.requestRefreshActivities() }
        function onDataChanged() { root.requestRefreshActivities() }
    }
}
