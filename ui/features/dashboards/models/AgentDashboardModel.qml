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
    readonly property alias recentBookingsModel: recentBookingsModelId
    readonly property alias notificationsModel: notificationsModelId
    readonly property alias disputesModel: disputesModelId

    ListModel {
        id: attentionModelId
        ListElement { title: "Acacia Studio"; reason: "Draft incomplete: missing photos"; actionLabel: "Complete draft" }
        ListElement { title: "Brookline Guest House"; reason: "Verification rejected: unclear ownership documents"; actionLabel: "Resubmit" }
        ListElement { title: "Palm Bungalow"; reason: "Verification pending for 5 days"; actionLabel: "Follow up" }
    }

    ListModel {
        id: recentBookingsModelId
        ListElement { client: "Brian P."; propertyTitle: "Sunview Apartments"; room: "Room B2"; amount: 25000; date: "22 Aug"; status: "Confirmed" }
        ListElement { client: "Faith C."; propertyTitle: "Green Court Hostel"; room: "Room 7"; amount: 12000; date: "22 Aug"; status: "Pending" }
        ListElement { client: "Chikondi B."; propertyTitle: "Palm Bungalow"; room: "Whole house"; amount: 40000; date: "21 Aug"; status: "Confirmed" }
        ListElement { client: "Mary Z."; propertyTitle: "Riverside Flats"; room: "Room A1"; amount: 32000; date: "20 Aug"; status: "Cancelled" }
    }

    ListModel {
        id: notificationsModelId
        ListElement { title: "New booking received"; message: "Green Court Hostel · Room 7 requested"; time: "2h ago"; unread: true }
        ListElement { title: "Verification approved"; message: "Sunview Apartments is now live"; time: "5h ago"; unread: false }
        ListElement { title: "Commission settled"; message: "MK 6,400 credited to your account"; time: "1d ago"; unread: false }
    }

    ListModel {
        id: disputesModelId
        ListElement { subject: "Refund request · BK-1042"; propertyName: "Riverside Flats"; state: "Open" }
        ListElement { subject: "Noise complaint · BK-1038"; propertyName: "Green Court Hostel"; state: "In review" }
    }
}
