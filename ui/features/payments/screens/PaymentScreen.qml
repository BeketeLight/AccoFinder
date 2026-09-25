import QtQuick 2.15
import "../../../utils" as UtilsModule
import "../pages"

Item {
    id: root

    property string bookingId: ""
    property real amount: 0

    PaymentsPage {
        anchors.fill: parent
        bookingId: root.bookingId
        amount: root.amount

        onPaymentSubmitted: function (bookingId, amount, method) {
            PaymentController.createPayment(bookingId, amount, method);
        }
    }

    Connections {
        target: PaymentController
        function onPaymentCreated(payment) {
            UtilsModule.NavigationUtils.pop({
                paymentId: payment.id
            });
        }
        function onPaymentError(error) {
            console.warn("Payment error:", error);
        }
    }
}
