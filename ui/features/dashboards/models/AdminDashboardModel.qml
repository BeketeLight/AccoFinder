import QtQuick

Item {
    id: root

    property string adminName: AppSettings.isLoggedIn() && AppSettings.userName().length > 0 ? AppSettings.userName() : "Admin"

    // Real stats sourced from the DashboardController (C++ -> API). Any value
    // that has no backend counterpart yet falls back to zero — no fake data is
    // ever shown on the cards. Each binding depends on refreshTick so the cards
    // re-evaluate whenever refreshed data arrives.
    property int refreshTick: 0
    property int totalUsers: DashboardController.totalUsers + refreshTick - refreshTick
    property int registeredAgents: DashboardController.totalAgents + refreshTick - refreshTick
    property int totalProperties: DashboardController.totalProperties + refreshTick - refreshTick
    property int pendingVerifications: DashboardController.pendingVerifications + refreshTick - refreshTick
    property int verifiedProperties: 0 + refreshTick - refreshTick
    property int openDisputes: 0 + refreshTick - refreshTick
    property int totalBookings: DashboardController.totalBookings + refreshTick - refreshTick
    property real totalBookingValue: DashboardController.totalBookingValue + refreshTick - refreshTick
    property real platformCommission: 0 + refreshTick - refreshTick

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

    Component.onCompleted: {
        DashboardController.refreshStats()
    }

    Connections {
        target: DashboardController
        function onStatsUpdated() { root.refreshStats() }
    }
}
