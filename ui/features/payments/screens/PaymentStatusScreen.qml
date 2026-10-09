import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../../../utils" as UtilsModule
import "../pages/PaymentStatusPage.qml" as Pages

Item {
    id: root

    // Injected by whoever pushes this screen
    property string bookingId: ""
    property string paymentId: ""
    property string chargeId: ""
    property real amount: 0

    // Provisional-hold deadline, fetched from the booking rather than pushed in:
    // this screen is normally reached from the payments history, where the
    // caller only knows the booking id. ISO string; empty means no live hold.
    property string holdExpiresAt: ""

    // Live status read from the last payment that arrived
    property int status: 0
    property string method: ""
    property string transactionRef: ""
    property string statusMessage: ""

    Timer {
        id: pollTimer
        interval: 4000
        repeat: true
        running: (root.status === 0 || root.status === 1) && root.chargeId.length > 0
        onTriggered: PaymentController.verifyPayment(root.chargeId)
    }

    Pages.PaymentStatusPage {
        anchors.fill: parent
        bookingId: root.bookingId
        paymentId: root.paymentId
        amount: root.amount
        status: root.status
        method: root.method
        transactionRef: root.transactionRef
        statusMessage: root.statusMessage

        onPayNowClicked: {
            UtilsModule.NavigationUtils.push(Qt.resolvedUrl("PaymentScreen.qml"), {
                bookingId: root.bookingId,
                amount: root.amount,
                holdExpiresAt: root.holdExpiresAt
            });
        }
    }

    Connections {
        target: BookingController

        function onBookingLoaded(booking) {
            if (!booking || booking.id !== root.bookingId)
                return;
            // Invalid QDateTime stringifies to "", which is exactly the
            // "no live hold" signal PaymentsPage expects.
            root.holdExpiresAt = booking.holdExpiresAt;
        }
    }

    Connections {
        target: PaymentController

        function onPaymentCreated(payment) {
            if (!payment)
                return;
            root.paymentId = payment.id;
            root.status = payment.status;
            root.method = payment.method;
            root.transactionRef = payment.transactionRef;
            root.statusMessage = qsTr("Payment initiated. Awaiting confirmation.");
            root.chargeId = payment.transactionRef;
        }
        function onPaymentLoaded(payment) {
            if (!payment)
                return;
            root.paymentId = payment.id;
            root.status = payment.status;
            root.method = payment.method;
            root.transactionRef = payment.transactionRef;
            root.amount = payment.amount;
            root.statusMessage = "";
        }
        function onPaymentRefunded(payment) {
            if (!payment)
                return;
            root.status = payment.status;
            root.statusMessage = qsTr("Payment was refunded.");
        }
        function onPaymentError(error) {
            root.status = 3;
            root.statusMessage = error;
        }
        function onPaymentVerified(payment) {
            if (!payment)
                return;
            root.status = payment.status;
            root.method = payment.method;
            root.transactionRef = payment.transactionRef;
            root.statusMessage = payment.bookingConfirmed ? qsTr("Payment confirmed and booking secured.") : qsTr("Payment succeeded, but the room is no longer available. " + "Support will contact you.");
            pollTimer.stop();
        }
        function onPaymentVerificationPending(payment) {
            if (!payment)
                return;
            root.status = payment.status;
            root.chargeId = payment.transactionRef;
            root.statusMessage = qsTr("Waiting for you to authorize the payment on your phone…");
        }
    }

    Component.onCompleted: {
        if (root.paymentId.length > 0)
            PaymentController.getPaymentById(root.paymentId);
        else if (root.bookingId.length > 0)
            PaymentController.refreshForBooking(root.bookingId);

        // Pay Now needs the hold deadline to show the countdown, so pull the
        // booking as well. Failure here is harmless: an unknown expiry simply
        // means the countdown is skipped.
        if (root.bookingId.length > 0)
            BookingController.fetchBookingById(root.bookingId);
    }
}
