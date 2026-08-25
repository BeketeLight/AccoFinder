import QtQuick

Item {
    id: root

    property string adminName: AppSettings.isLoggedIn() && AppSettings.userName().length > 0 ? AppSettings.userName() : "Admin"

    // System overview
    property int totalUsers: 1284
    property int registeredAgents: 36
    property int totalProperties: 214
    property int pendingVerifications: 9
    property int verifiedProperties: 168
    property int openDisputes: 4
    property int totalBookings: 512
    property real totalBookingValue: 4820000
    property real platformCommission: 241000

    // Payment & commission oversight summary
    property real paymentsCollected: 4579000
    property int paymentsPendingSettlement: 6
    property real agentCommissionsDue: 38400
    property int ownerPayoutsPending: 3

    readonly property alias pendingActivitiesModel: pendingActivitiesModelId

    ListModel {
        id: pendingActivitiesModelId
        ListElement { title: "9 properties awaiting verification"; detail: "Oldest waiting since 19 Aug"; kind: "approvals" }
        ListElement { title: "3 owner payouts pending"; detail: "MK 96,500 due for release"; kind: "payments" }
        ListElement { title: "4 open disputes"; detail: "2 escalated beyond 48 hours"; kind: "disputes" }
        ListElement { title: "2 agent applications"; detail: "Chilumba M., Yankho N."; kind: "agents" }
    }
}
