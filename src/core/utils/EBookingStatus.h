#ifndef EBOOKINGSTATUS_H
#define EBOOKINGSTATUS_H

// Mirrors the backend BookingStatus enum (src/models/enums/BookingStatus.mjs).
// The string form of each value is what the API sends, so the parser in
// bookinglistmodel.cpp switches on these names.
//
// Lifecycle: PendingPayment -> PaymentInFlight -> Confirmed, with Expired and
// Cancelled as the two ways a hold ends without a payment. Only Confirmed
// means the room is permanently booked.
enum class BookingStatus {
    PendingPayment,   // "PendingPayment"   hold active, awaiting payment
    PaymentInFlight,  // "PaymentInFlight"  sent to provider, not yet verified
    Confirmed,        // "Confirmed"        paid; room permanently booked
    Expired,          // "Expired"          hold lapsed, room released
    Cancelled,        // "Cancelled"        user backed out, room released
    Failed,           // "Failed"           payment failed, hold still retryable

    // Legacy values kept so historical bookings still render. The hold model
    // no longer produces either of these.
    Pending,
    Paid
};

#endif // EBOOKINGSTATUS_H
