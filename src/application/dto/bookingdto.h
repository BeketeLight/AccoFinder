#ifndef BOOKINGDTO_H
#define BOOKINGDTO_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include "models/booking.h"

class BookingDto
{
public:
    BookingDto();

    BookingDto(
        const QString& id,
        const QString& clientId,
        const QString& roomId,
        const QDateTime& bookingDate,
        const QString& status,
        double amount,
        double commissionAmount
        );

    QString id;
    QString clientId;
    QString roomId;
    QDateTime bookingDate;
    QString status;
    double amount;
    double commissionAmount;

    static BookingDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    Booking* toDomainModel() const;
};

#endif // BOOKINGDTO_H