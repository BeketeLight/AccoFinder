import QtQuick 2.15
import "../pages"
import "../../../utils" as NavUtils

Item {
    id: paymentScreenId

    property var bookingDetails: null
    property var operators: []
    property string phase: "form"
    property string currentTxRef: ""

    // Booking context from the Book Now flow. holdExpiresAt is the provisional
    // hold deadline (ISO string from the API) and drives the countdown on the
    // payment page.
    property string bookingId: ""
    property real amount: 0
    property var holdExpiresAt: null

    PaymentsPage {
        anchors.fill: parent
        bookingId: paymentScreenId.bookingId
        amount: paymentScreenId.amount
        holdExpiresAt: paymentScreenId.holdExpiresAt
        bookingDetails: paymentScreenId.bookingDetails
        operators: paymentScreenId.operators
        phase: paymentScreenId.phase
        onPaymentSubmitted: function (bookingId, amount, method, operatorRefId, phoneNumber) {
            PaymentController.createPayment(bookingId, amount, method, operatorRefId, phoneNumber);
        }
    }

    Connections {
        target: PaymentController
        function onOperatorsLoaded(ops) {
            console.log("available operators:", JSON.stringify(ops));
            paymentScreenId.operators = ops;
        }
        function onOperatorsError(err) {
            console.warn("Operators:", err);
        }

        function onPaymentCreated(payment) {
            if (!payment)
                return;
            paymentScreenId.currentTxRef = payment.transactionRef;
            paymentScreenId.phase = "awaitingPin";
            pollTimer.start();
        }

        function onPaymentVerified(payment) {
            pollTimer.stop();
            paymentScreenId.phase = "done";
            NavUtils.NavigationUtils.pop({
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
            paymentScreenId.phase = "done";
            UtilsModule.NavigationUtils.pop({
                bookingId: paymentScreenId.bookingId,
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
            if (paymentScreenId.currentTxRef.length > 0)
                PaymentController.verifyPayment(paymentScreenId.currentTxRef);
        }
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationActive && paymentScreenId.phase === "awaitingPin" && paymentScreenId.currentTxRef.length > 0) {
                PaymentController.verifyPayment(paymentScreenId.currentTxRef);
            }
        }
    }

    Component.onCompleted: {
        if (paymentScreenId.operators.length === 0)
            PaymentController.fetchOperators();
        if (!paymentScreenId.bookingDetails && paymentScreenId.bookingId.length > 0)
            BookingController.fetchBookingById(paymentScreenId.bookingId);
    }
}
