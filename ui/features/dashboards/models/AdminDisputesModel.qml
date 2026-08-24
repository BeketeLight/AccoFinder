import QtQuick

Item {
    id: root

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
        for (var i = 0; i < disputesModelId.count; i++) {
            var d = disputesModelId.get(i)
            if (d.disputeId === disputeId) {
                d.status = status
                disputesModelId.set(i, d)
                break
            }
        }
        refresh()
    }

    ListModel {
        id: disputesModelId

        ListElement {
            disputeId: "DS-201"
            subject: "Refund request · BK-1042"
            property: "Riverside Flats"
            client: "Chikondi Banda"
            opened: "22 Aug 2026"
            status: "Open"
            detail: "Client reports the room was not cleaned and requests a full refund of MK 32,000. Landlord claims the room was handed over in good condition."
        }
        ListElement {
            disputeId: "DS-202"
            subject: "Noise complaint · BK-1038"
            property: "Green Court Hostel"
            client: "Faith Chirwa"
            opened: "21 Aug 2026"
            status: "In review"
            detail: "Client complains about ongoing construction noise during booked dates. Requests partial refund of MK 6,000 for two disturbed nights."
        }
        ListElement {
            disputeId: "DS-203"
            subject: "Double charge · BK-1031"
            property: "Palm Bungalow"
            client: "Mary Zimba"
            opened: "18 Aug 2026"
            status: "Resolved"
            detail: "Duplicate mobile money deduction confirmed by payment gateway. Refund of MK 40,000 processed on 20 Aug."
        }
        ListElement {
            disputeId: "DS-204"
            subject: "Amenities missing · BK-1027"
            property: "Acacia Studio"
            client: "Tapiwa Gondwe"
            opened: "15 Aug 2026"
            status: "Rejected"
            detail: "Client claimed no water supply. Investigation showed the outage was a district-wide issue outside the landlord's control."
        }
    }

    ListModel { id: viewModelId }

    Component.onCompleted: refresh()
}
