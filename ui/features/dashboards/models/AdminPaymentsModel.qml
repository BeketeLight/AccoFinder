import QtQuick

Item {
    id: root

    // Delegate-facing API preserved. Backend payment/commission/payout admin
    // endpoints do not exist yet, so the models stay empty and the pages show
    // their empty-state messages until a backend source is wired in.
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
    }

    ListModel {
        id: commissionsModelId
    }

    ListModel {
        id: payoutsModelId
    }

    Component.onCompleted: refresh()
}
