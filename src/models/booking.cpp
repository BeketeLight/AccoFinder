#include "booking.h"

Booking::Booking(QObject *parent)
    :QObject(parent)
{}

Booking::Booking(QString &newId, QString newClientId, QString newRoomId, QDateTime newBookingDate, BookingStatus newStatus, double newAmount, double newCommissionAmount)
{
    id =newId;
    clientId = newClientId;
    roomId = newRoomId;
    bookingDate = newBookingDate;
    status = newStatus;
    amount = newAmount;
    commissionAmount = newCommissionAmount;

    emit bookingConfirmed();

}

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
    if (getStatus() == BookingStatus::Cancelled)
        emit bookingCancelled();
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
