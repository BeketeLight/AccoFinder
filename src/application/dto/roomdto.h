#ifndef ROOMDTO_H
#define ROOMDTO_H

#include <QJsonObject>
#include <QDateTime>
#include"models/room.h"


class RoomDto
{
public:
    RoomDto();
    RoomDto(const QString& id,
            const QString& propertyId,
            const QString& type,
            double price,
            bool available,
            bool holdActive = false,
            const QDateTime& holdExpiresAt = QDateTime());


    QString m_id;
    QString m_propertyId;
    QString m_type;
    double m_price = 0;
    bool m_available;
    bool m_holdActive = false;
    QDateTime m_holdExpiresAt;


    static RoomDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    QSharedPointer<Room> toDomainModel() const;
};

#endif // ROOMDTO_H
