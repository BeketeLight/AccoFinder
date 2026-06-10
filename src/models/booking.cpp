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
    :m_id(id)
    ,m_clientId(clientId)
    ,m_bookingDate(bookingDate)
    ,m_amount(amount)
    ,m_commissionAmount(commissionAmount)
    ,QObject(parent)
{
    emit bookingCreated();

}

QString Booking::getId() const
{
    return m_id;
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
    m_id = newId;
}

void Booking::setClientId(const QString &newClientId)
{
    m_clientId = newClientId;
}

void Booking::setRoomId(const QString &newRoomId)
{
    m_roomId = newRoomId;
}

void Booking::setBookingDate(const QDateTime &newBookingDate)
{
    m_bookingDate = newBookingDate;
}

void Booking::setAmount(double newAmount)
{
    m_amount = newAmount;
}

void Booking::setCommissionAmount(double newCommissionAmount)
{
    m_commissionAmount = newCommissionAmount;
}

