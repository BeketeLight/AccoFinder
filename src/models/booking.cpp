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
    m_status = status;
    if (getStatus() == BookingStatus::Cancelled)
        emit bookingCancelled();
    else if (getStatus() == BookingStatus::Paid)
        emit bookingFeePaid();
    else if (getStatus() == BookingStatus::Confirmed)
        emit bookingConfirmed();
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

