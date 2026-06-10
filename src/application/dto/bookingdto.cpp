#include "bookingdto.h"

BookingDto::BookingDto()
    : amount(0.0),
    commissionAmount(0.0)
{
}

BookingDto::BookingDto(
    const QString& id,
    const QString& clientId,
    const QString& roomId,
    const QDateTime& bookingDate,
    const QString& status,
    double amount,
    double commissionAmount)
    : id(id),
    clientId(clientId),
    roomId(roomId),
    bookingDate(bookingDate),
    status(status),
    amount(amount),
    commissionAmount(commissionAmount)
{
}
BookingDto BookingDto::fromJson(
    const QJsonObject& json)
{
    BookingDto dto;

    dto.id =
        json["id"].toString();

    dto.clientId =
        json["clientId"].toString();

    dto.roomId =
        json["roomId"].toString();

    dto.bookingDate =
        QDateTime::fromString(
            json["bookingDate"].toString(),
            Qt::ISODate);

    dto.status =
        json["status"].toString();

    dto.amount =
        json["amount"].toDouble();

    dto.commissionAmount =
        json["commissionAmount"].toDouble();

    return dto;
}

QJsonObject BookingDto::toJson() const
{
    QJsonObject json;

    json["id"] = id;
    json["clientId"] = clientId;
    json["roomId"] = roomId;
    json["bookingDate"] =
        bookingDate.toString(Qt::ISODate);

    json["status"] = status;
    json["amount"] = amount;
    json["commissionAmount"] = commissionAmount;

    return json;
}

Booking* BookingDto::toDomainModel() const
{
    Booking* booking = new Booking();

    booking->setId(id);
    booking->setClientId(clientId);
    booking->setRoomId(roomId);
    booking->setBookingDate(bookingDate);

    // Assuming BookingStatus enum conversion exists
    // booking->setStatus(...);

    booking->setAmount(amount);
    booking->setCommissionAmount(
        commissionAmount);

    return booking;
}