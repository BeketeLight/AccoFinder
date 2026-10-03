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

    // Provisional hold deadline. Absent on non-hold bookings, which leaves the
    // QDateTime invalid - the signal for "no countdown to show".
    const QString holdExpiry =
        json["expiresAt"].toString();

    if (!holdExpiry.isEmpty()) {
        dto.holdExpiresAt =
            QDateTime::fromString(holdExpiry, Qt::ISODate);

        if (!dto.holdExpiresAt.isValid()) {
            dto.holdExpiresAt =
                QDateTime::fromString(holdExpiry, Qt::ISODateWithMs);
        }
    }

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

    if (holdExpiresAt.isValid()) {
        json["expiresAt"] =
            holdExpiresAt.toUTC().toString(Qt::ISODate);
    }

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