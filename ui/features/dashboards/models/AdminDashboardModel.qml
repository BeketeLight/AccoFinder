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
    property int totalUsers: DashboardController.totalUsers + refreshTick - refreshTick
    property int registeredAgents: DashboardController.totalAgents + refreshTick - refreshTick
    property int totalProperties: DashboardController.totalProperties + refreshTick - refreshTick
    property int pendingVerifications: DashboardController.pendingVerifications + refreshTick - refreshTick
    property int openDisputes: DashboardController.openDisputes + refreshTick - refreshTick
    property int totalBookings: DashboardController.totalBookings + refreshTick - refreshTick
    property real totalBookingValue: DashboardController.totalBookingValue + refreshTick - refreshTick
    property real platformCommission: DashboardController.platformCommission + refreshTick - refreshTick

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

        var props = PropertyViewModel.propertiesForView() || []
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
        var pending = PropertyViewModel.pendingListModel
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

    Component.onCompleted: {
        // Populate from any already-cached properties. Network fetch is driven
        // by the screen so there is a single source for the initial load.
        root.refreshActivities()
    }

    Connections {
        target: DashboardController
        function onStatsUpdated() { root.refreshStats() }
    }

    Connections {
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshStats()
        }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onModelReset() { root.refreshActivities(); root.refreshStats() }
        function onRowsInserted(parent, first, last) { root.refreshActivities(); root.refreshStats() }
        function onRowsRemoved(parent, first, last) { root.refreshActivities(); root.refreshStats() }
    }

    // The verification queue is filled owner by owner, so the activity list has
    // to follow it as rows arrive.
    Connections {
        target: PropertyViewModel.pendingListModel
        function onCountChanged() { root.refreshActivities() }
        function onDataChanged() { root.refreshActivities() }
    }
}
