import QtQuick 2.15
import "../../../utils" as UtilsModule
import "../pages"

Item {
    id: root

    property string bookingId: ""
    property real amount: 0
    property var bookingDetails: null
    property var operators: []
    property string currentTxRef: ""
    property string phase: "form"     // "form" | "awaitingPin" | "done"

    // Provisional-hold deadline as an ISO string. Empty means the booking has no
    // live hold, in which case PaymentsPage skips the countdown and leaves
    // payment enabled.
    property string holdExpiresAt: ""

    PaymentsPage {
        anchors.fill: parent
        bookingId: root.bookingId
        amount: root.amount
        holdExpiresAt: root.holdExpiresAt
        bookingDetails: root.bookingDetails
        operators: root.operators
        phase: root.phase

        onPaymentSubmitted: function (bookingId, amount, method, operatorRefId, phoneNumber) {
            console.log("pay now button clicked on payment");
            PaymentController.createPayment(bookingId, amount, method, operatorRefId, phoneNumber);
        }
    }

    Connections {
        target: PaymentController
        function onOperatorsLoaded(ops) {
            root.operators = ops;
        }
        function onOperatorsError(err) {
            console.warn("Operators:", err);
        }

        function onPaymentCreated(payment) {
            if (!payment)
                return;
            root.currentTxRef = payment.transactionRef;
            root.phase = "awaitingPin";
            pollTimer.start();
            // UtilsModule.NavigationUtils.pop({
            //     paymentId: payment.id
            // });
        }
        // function onPaymentError(error) {
        //     console.warn("Payment error:", error);
        // }
        function onPaymentVerified(payment) {
            pollTimer.stop();
            root.phase = "done";
            UtilsModule.NavigationUtils.pop({
                bookingId: root.bookingId,
                paymentId: payment ? payment.id : "",
                succeeded: payment && payment.status === 2,
                bookingConfirmed: payment ? payment.bookingConfirmed : false
            });
        }

        function onPaymentVerificationPending(payment) {
            // Still INITIATED on the provider. Keep polling.
        }

        function onPaymentError(error) {
            pollTimer.stop();
            root.phase = "done";
            UtilsModule.NavigationUtils.pop({
                bookingId: root.bookingId,
                succeeded: false
            });
        }
    }

    Timer {
        id: pollTimer
        interval: 4000
        repeat: true
        running: false
        onTriggered: {
            if (root.currentTxRef.length > 0)
                PaymentController.verifyPayment(root.currentTxRef);
        }
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationActive && root.phase === "awaitingPin" && root.currentTxRef.length > 0) {
                PaymentController.verifyPayment(root.currentTxRef);
            }
        }
    }

    Component.onCompleted: {
        if (root.operators.length === 0)
            PaymentController.fetchOperators();
        if (!root.bookingDetails && root.bookingId.length > 0)
            BookingController.fetchBookingById(root.bookingId);
    }
}
