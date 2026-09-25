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
    property real amount: 0

    // Live status read from the last payment that arrived
    property int status: 0
    property string method: ""
    property string transactionRef: ""
    property string statusMessage: ""

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
                amount: root.amount
            });
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
    }

    Component.onCompleted: {
        if (root.paymentId.length > 0)
            PaymentController.getPaymentById(root.paymentId);
        else if (root.bookingId.length > 0)
            PaymentController.refreshForBooking(root.bookingId);
    }
}
