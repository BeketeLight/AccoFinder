import QtQuick 2.15
import "../pages"

Item {
    id: paymentScreenId

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
    }
}