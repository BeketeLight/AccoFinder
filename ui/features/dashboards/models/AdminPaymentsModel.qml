import QtQuick

Item {
    id: root

    // Real data is sourced from the C++ PaymentsOverviewViewModel
    // (PaymentOverviewRepository -> /dashboard/payments API). Summary cards and
    // the three tab lists are populated from the backend aggregation, so no
    // value is hard-coded — a metric with no data yet returns 0 from the API.
    readonly property alias paymentsModel: paymentsModelId
    readonly property alias commissionsModel: commissionsModelId
    readonly property alias payoutsModel: payoutsModelId

    property real totalCollected: PaymentsOverviewViewModel.totalCollected
    property int pendingCount: PaymentsOverviewViewModel.pendingCount
    property real commissionsDue: PaymentsOverviewViewModel.commissionsDue
    property int payoutsPending: PaymentsOverviewViewModel.payoutsPending

    function refresh() {
        root.totalCollected = PaymentsOverviewViewModel.totalCollected
        root.pendingCount = PaymentsOverviewViewModel.pendingCount
        root.commissionsDue = PaymentsOverviewViewModel.commissionsDue
        root.payoutsPending = PaymentsOverviewViewModel.payoutsPending
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

    // ---- Backend-backed admin actions ----
    // The view model posts to the API, refreshes the overview on success and
    // emits commissionSettled/payoutReleased/actionFailed. No local-only
    // mutation is performed here.
    function settleCommission(agentName, paymentId, bookingId, agentId) {
        PaymentsOverviewViewModel.settleCommission(agentName || "",
                                                   paymentId || "",
                                                   bookingId || "",
                                                   agentId || "")
    }

    function releasePayout(landlord, paymentId, bookingId, landlordId) {
        PaymentsOverviewViewModel.releasePayout(landlord || "",
                                                paymentId || "",
                                                bookingId || "",
                                                landlordId || "")
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

    function reload() {
        paymentsModelId.clear()
        commissionsModelId.clear()
        payoutsModelId.clear()

        var p = PaymentsOverviewViewModel.paymentsModel
        for (var i = 0; i < p.size(); i++)
            paymentsModelId.append(p.at(i))

        var c = PaymentsOverviewViewModel.commissionsModel
        for (var j = 0; j < c.size(); j++)
            commissionsModelId.append(c.at(j))

        var o = PaymentsOverviewViewModel.payoutsModel
        for (var k = 0; k < o.size(); k++)
            payoutsModelId.append(o.at(k))

        refresh()
    }

    Connections {
        target: PaymentsOverviewViewModel.paymentsModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Connections {
        target: PaymentsOverviewViewModel.commissionsModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Connections {
        target: PaymentsOverviewViewModel.payoutsModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Component.onCompleted: {
        root.reload()
        PaymentsOverviewViewModel.refresh()
    }
}