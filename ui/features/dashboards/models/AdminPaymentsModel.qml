import QtQuick

Item {
    id: root

    readonly property alias paymentsModel: paymentsModelId
    readonly property alias commissionsModel: commissionsModelId
    readonly property alias payoutsModel: payoutsModelId

    property real totalCollected: 0
    property int pendingCount: 0
    property real commissionsDue: 0
    property int payoutsPending: 0

    function refresh() {
        var collected = 0
        var pending = 0
        for (var i = 0; i < paymentsModelId.count; i++) {
            var p = paymentsModelId.get(i)
            if (p.status === "Completed") collected += p.amount
            else if (p.status === "Pending") pending++
        }
        var due = 0
        for (var j = 0; j < commissionsModelId.count; j++) {
            var c = commissionsModelId.get(j)
            if (c.status === "Due") due += c.amount
        }
        var payoutPending = 0
        for (var k = 0; k < payoutsModelId.count; k++) {
            if (payoutsModelId.get(k).status === "Pending") payoutPending++
        }
        root.totalCollected = collected
        root.pendingCount = pending
        root.commissionsDue = due
        root.payoutsPending = payoutPending
    }

    function setPaymentStatus(paymentId, status) {
        for (var i = 0; i < paymentsModelId.count; i++) {
            var p = paymentsModelId.get(i)
            if (p.paymentId === paymentId) {
                p.status = status
                paymentsModelId.set(i, p)
                break
            }
        }
        refresh()
    }

    function setCommissionStatus(agentName, status) {
        for (var j = 0; j < commissionsModelId.count; j++) {
            var c = commissionsModelId.get(j)
            if (c.agent === agentName) {
                c.status = status
                commissionsModelId.set(j, c)
                break
            }
        }
        refresh()
    }

    function setPayoutStatus(landlord, status) {
        for (var k = 0; k < payoutsModelId.count; k++) {
            var o = payoutsModelId.get(k)
            if (o.landlord === landlord) {
                o.status = status
                payoutsModelId.set(k, o)
                break
            }
        }
        refresh()
    }

    ListModel {
        id: paymentsModelId

        ListElement { paymentId: "BK-1042"; user: "Chikondi Banda"; kind: "Booking · Riverside Flats A1"; amount: 32000; method: "Mobile money"; date: "23 Aug 2026"; status: "Completed" }
        ListElement { paymentId: "BK-1043"; user: "Memory Phiri"; kind: "Booking · Green Court Hostel 7"; amount: 12000; method: "Bank transfer"; date: "23 Aug 2026"; status: "Pending" }
        ListElement { paymentId: "BK-1040"; user: "Blessings Nkhoma"; kind: "Booking · Palm Bungalow"; amount: 40000; method: "Mobile money"; date: "22 Aug 2026"; status: "Completed" }
        ListElement { paymentId: "BK-1038"; user: "Faith Chirwa"; kind: "Booking · Sunview Apartments B2"; amount: 25000; method: "Card"; date: "21 Aug 2026"; status: "Disputed" }
        ListElement { paymentId: "BK-1036"; user: "Tapiwa Gondwe"; kind: "Booking · Acacia Studio"; amount: 85000; method: "Bank transfer"; date: "20 Aug 2026"; status: "Refunded" }
        ListElement { paymentId: "BK-1035"; user: "Yamikani Sibale"; kind: "Booking · Brookline Guest House"; amount: 55000; method: "Mobile money"; date: "19 Aug 2026"; status: "Completed" }
    }

    ListModel {
        id: commissionsModelId

        ListElement { agent: "Yankho Mwale"; area: "Lilongwe"; bookings: 14; amount: 18600; rate: 10; status: "Due" }
        ListElement { agent: "Fatsani Zimba"; area: "Mzuzu"; bookings: 9; amount: 9750; rate: 8; status: "Settled" }
        ListElement { agent: "Dalitso Kachale"; area: "Zomba"; bookings: 11; amount: 12400; rate: 10; status: "Due" }
        ListElement { agent: "Chilumba Chirwa"; area: "Blantyre"; bookings: 4; amount: 3100; rate: 12; status: "On hold" }
    }

    ListModel {
        id: payoutsModelId

        ListElement { landlord: "Alinafe Buleya"; property: "Riverside Flats"; amount: 96500; period: "Aug 2026"; status: "Pending" }
        ListElement { landlord: "Tapiwa Gondwe"; property: "Green Court Hostel"; amount: 54000; period: "Aug 2026"; status: "Paid" }
        ListElement { landlord: "Grace Mvula"; property: "Sunview Apartments"; amount: 71200; period: "Jul 2026"; status: "Paid" }
    }

    Component.onCompleted: refresh()
}
