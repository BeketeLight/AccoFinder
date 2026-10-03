#include "booking.h"

Booking::Booking(QObject *parent)
    :QObject(parent)
{

}

Booking::Booking(const QString &id,
                 const QString &clientId,
                 const QString &roomId,
                 const QDateTime &bookingDate,
                 const double &amount,
                 const double &commissionAmount,
                 QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_clientId(clientId)
    , m_roomId(roomId)
    , m_bookingDate(bookingDate)
    , m_status(BookingStatus::Pending)
    , m_amount(amount)
    , m_commissionAmount(commissionAmount)
{
    emit bookingCreated();

}

QString Booking::getId() const
{
    return m_id;
}

QString Booking::getClientId() const
{
    return m_clientId;
}
QString Booking::getClientName() const
{
    return m_clientName;
}
QString Booking::getClientEmail() const
{
    return m_clientEmail;
}
QString Booking::getClientPhone() const
{
    return m_clientPhone;
}

QString Booking::getRoomId() const
{
    return m_roomId;
}


QDateTime Booking::getBookingDate() const
{
    return m_bookingDate;
}


BookingStatus Booking::getStatus() const
{
    return m_status;
}

void Booking::setStatus(const BookingStatus& status)
{
    if (m_status == status)
        return;

    m_status = status;
    emit statusChanged();

    // Keep the countdown consistent with the new status. A booking that no
    // longer holds a room must not keep rendering time remaining.
    refreshHoldCountdown();

    if (getStatus() == BookingStatus::Cancelled)
        emit bookingCancelled();
    else if (getStatus() == BookingStatus::Expired)
        emit bookingExpired();
    else if (getStatus() == BookingStatus::Paid)
        emit bookingFeePaid();
    else if (getStatus() == BookingStatus::Confirmed)
        emit bookingConfirmed();
}

QString Booking::getStatusString() const
{
    // Display labels. Kept in sync with bookingStatusToString() in
    // bookinglistmodel.cpp, which produces the same text for list delegates.
    switch (m_status) {
    case BookingStatus::PendingPayment:  return QStringLiteral("Pending payment");
    case BookingStatus::PaymentInFlight: return QStringLiteral("Payment processing");
    case BookingStatus::Confirmed:       return QStringLiteral("Confirmed");
    case BookingStatus::Expired:         return QStringLiteral("Expired");
    case BookingStatus::Cancelled:       return QStringLiteral("Cancelled");
    case BookingStatus::Failed:          return QStringLiteral("Payment failed");
    case BookingStatus::Pending:         return QStringLiteral("Pending");
    case BookingStatus::Paid:            return QStringLiteral("Paid");
    }
    return QStringLiteral("Pending");
}

QDateTime Booking::getHoldExpiresAt() const
{
    return m_holdExpiresAt;
}

void Booking::setHoldExpiresAt(const QDateTime &newHoldExpiresAt)
{
    // An invalid QDateTime means "no live hold" and is stored as-is - it is the
    // signal refreshHoldCountdown() and the UI read to decide whether to show a
    // countdown at all. (It used to recurse into itself here with a fresh
    // invalid value, which overflowed the stack on every booking payload that
    // carries no expiresAt.)
    //
    // Valid values are normalised to UTC. The API sends an ISO instant and the
    // countdown is computed against currentDateTimeUtc(), so storing a
    // local-time QDateTime here would silently skew the remaining time by the
    // device's UTC offset.
    const QDateTime asUtc = newHoldExpiresAt.isValid()
                                ? newHoldExpiresAt.toUTC()
                                : QDateTime();
    if (m_holdExpiresAt == asUtc)
        return;

    m_holdExpiresAt = asUtc;
    emit holdExpiresAtChanged();
    refreshHoldCountdown();
}

int Booking::getHoldSecondsRemaining() const
{
    return m_holdSecondsRemaining;
}

bool Booking::getHoldActive() const
{
    return m_holdSecondsRemaining > 0;
}

void Booking::refreshHoldCountdown()
{
    // Only statuses that actually hold inventory get a countdown. Expired and
    // cancelled hold nothing, and a confirmed booking owns the room outright.
    const bool holdsRoom =
        m_status == BookingStatus::PendingPayment
        || m_status == BookingStatus::PaymentInFlight
        || m_status == BookingStatus::Failed
        || m_status == BookingStatus::Pending;

    const int remaining =
        (holdsRoom && m_holdExpiresAt.isValid())
            ? static_cast<int>(QDateTime::currentDateTimeUtc()
                                   .secsTo(m_holdExpiresAt))
            : 0;

    const int clamped = qMax(0, remaining);

    if (m_holdSecondsRemaining != clamped) {
        m_holdSecondsRemaining = clamped;
        emit holdSecondsRemainingChanged();
        emit holdActiveChanged();
    }
}

double Booking::getAmount() const
{
    return m_amount;
}

double Booking::getCommissionAmount() const
{
    return m_commissionAmount;
}

void Booking::setId(const QString &newId)
{
    if (m_id == newId) return;
    m_id = newId;
    emit idChanged();
}

void Booking::setClientId(const QString &newClientId)
{
    if (m_clientId == newClientId) return;
    m_clientId = newClientId;
    emit clientIdChanged();
}

void Booking::setClientName(const QString &newClientName)
{
    if(m_clientName == newClientName) return;
    m_clientName = newClientName;
    emit clientNameChanged();
}
void Booking::setClientEmail(const QString &newClientEmail)
{
    if(m_clientEmail == newClientEmail) return;
    m_clientEmail = newClientEmail;
    emit clientEmailChanged();
}
void Booking::setClientPhone(const QString &newClientPhone)
{
    if(m_clientPhone == newClientPhone) return;
    m_clientPhone = newClientPhone;
    emit clientPhoneChanged();
}

void Booking::setRoomId(const QString &newRoomId)
{
    if (m_roomId == newRoomId) return;
    m_roomId = newRoomId;
    emit roomIdChanged();
}

void Booking::setBookingDate(const QDateTime &newBookingDate)
{
    if (m_bookingDate == newBookingDate) return;
    m_bookingDate = newBookingDate;
    emit bookingDateChanged();
}

void Booking::setAmount(double newAmount)
{
    if (qFuzzyCompare(m_amount, newAmount)) return;
    m_amount = newAmount;
    emit amountChanged();
}

void Booking::setCommissionAmount(double newCommissionAmount)
{
    if (qFuzzyCompare(m_commissionAmount, newCommissionAmount)) return;
    m_commissionAmount = newCommissionAmount;
     emit commissionAmountChanged();
}

