import QtQuick 2.15

Item {
    id: root

    readonly property alias paymentsModel: paymentsModelId
    readonly property int count: paymentsModelId.count
    readonly property bool loading: PaymentController.isLoading

    ListModel {
        id: paymentsModelId
    }

    function reload() {
        paymentsModelId.clear();
        var m = PaymentController.paymentListModel;
        var n = m ? m.size() : 0;
        for (var i = 0; i < n; i++) {
            var item = m.at(i);
            paymentsModelId.append({
                paymentId: String(item.paymentId || item.id || ""),
                bookingId: String(item.bookingId || ""),
                amount: Number(item.amount || 0),
                method: String(item.method || ""),
                status: Number(item.status || 0),
                transactionRef: String(item.transactionRef || ""),
                payoutStatus: String(item.payoutStatus || ""),
                payoutDate: item.payoutDate || null,
                paidAt: item.paidAt || null
            });
        }
    }

    Component.onCompleted: reload()

    Connections {
        target: PaymentController.paymentListModel
        function onCountChanged() {
            root.reload();
        }
        function onDataChanged() {
            root.reload();
        }
        function onModelReset() {
            root.reload();
        }
        function onRowsInserted() {
            root.reload();
        }
        function onRowsRemoved() {
            root.reload();
        }
    }
}
