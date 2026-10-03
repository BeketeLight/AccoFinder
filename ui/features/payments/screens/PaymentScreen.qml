import QtQuick 2.15
import "../../../utils" as UtilsModule
import "../pages"

Item {
    id: root

    property string bookingId: ""
    property real amount: 0

    // Provisional-hold deadline as an ISO string. Empty means the booking has no
    // live hold, in which case PaymentsPage skips the countdown and leaves
    // payment enabled.
    property string holdExpiresAt: ""

    PaymentsPage {
        anchors.fill: parent
        bookingId: root.bookingId
        amount: root.amount
        holdExpiresAt: root.holdExpiresAt

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
