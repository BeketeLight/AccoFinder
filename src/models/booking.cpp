#include "booking.h"

Booking::Booking(QObject *parent)
    :QObject(parent)
{}

QString Booking::getId() const
{
    return id;
}

void Booking::setId(const QString &newId)
{
    id = newId;
}

QString Booking::getClientId() const
{
    return clientId;
}

void Booking::setClientId(const QString &newClientId)
{
    clientId = newClientId;
}

QString Booking::getRoomId() const
{
    return roomId;
}

void Booking::setRoomId(const QString &newRoomId)
{
    roomId = newRoomId;
}

QDateTime Booking::getBookingDate() const
{
    return bookingDate;
}

void Booking::setBookingDate(const QDateTime &newBookingDate)
{
    bookingDate = newBookingDate;
}

BookingStatus Booking::getStatus() const
{
    return status;
}

void Booking::setStatus(BookingStatus newStatus)
{
    status = newStatus;
}

double Booking::getAmount() const
{
    return amount;
}

void Booking::setAmount(double newAmount)
{
    amount = newAmount;
}

double Booking::getCommissionAmount() const
{
    return commissionAmount;
}

void Booking::setCommissionAmount(double newCommissionAmount)
{
    commissionAmount = newCommissionAmount;
}
