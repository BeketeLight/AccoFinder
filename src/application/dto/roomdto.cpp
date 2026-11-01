#include "roomdto.h"

RoomDto::RoomDto() {}

RoomDto::RoomDto(const QString &id,
                 const QString &propertyId,
                 const QString &type,
                 double price,
                 bool available,
                 bool holdActive,
                 const QDateTime &holdExpiresAt)
    :m_id(id)
    ,m_propertyId(propertyId)
    ,m_type(type)
    ,m_price(price)
    ,m_available(available)
    ,m_holdActive(holdActive)
    ,m_holdExpiresAt(holdExpiresAt)
{

}

RoomDto RoomDto::fromJson(const QJsonObject &json)
{
    RoomDto dto;

    // The backend returns id under "_id". propertyId may be either a plain
    // string id or a nested {_id,...} object (as /rooms/ returns it).
    dto.m_id = json["_id"].toString();
    if (dto.m_id.isEmpty())
        dto.m_id = json["id"].toString();

    const QJsonValue propRef = json["propertyId"];
    if (propRef.isObject())
        dto.m_propertyId = propRef.toObject()["_id"].toString();
    else
        dto.m_propertyId = propRef.toString();

    dto.m_available = json["available"].toBool();

    // Hold decoration added by the backend on every room listing. Defaults are
    // safe for older payloads that predate the hold model.
    dto.m_holdActive = json["holdActive"].toBool();
    const QString hold = json["holdExpiresAt"].toString();
    if (!hold.isEmpty())
        dto.m_holdExpiresAt = QDateTime::fromString(hold, Qt::ISODateWithMs);

    dto.m_type = json["type"].toString();

    // The backend exposes the rent as `rentalFee` and the platform fee as
    // `bookingFee`; keep `price` as a fallback for older payloads.
    dto.m_price = json.contains("rentalFee")
                      ? json["rentalFee"].toDouble()
                      : json["price"].toDouble();
    dto.m_bookingFee = json["bookingFee"].toDouble();

    return dto;
}

QJsonObject RoomDto::toJson() const
{

    QJsonObject json;

    json["id"] =
        m_id;

    json["propertyId"] = m_propertyId;

    json["type"] =
        m_type;

    json["rentalFee"] = m_price;

    json["bookingFee"] = m_bookingFee;

    json["available"] =
        m_available;

    json["holdActive"] = m_holdActive;

    if (m_holdExpiresAt.isValid())
        json["holdExpiresAt"] = m_holdExpiresAt.toString(Qt::ISODateWithMs);

        return json;
}

QSharedPointer<Room> RoomDto::toDomainModel() const
{
    return QSharedPointer<Room>::create(m_id,m_propertyId,m_type,m_price,m_available,
                                        m_holdActive,m_holdExpiresAt);
}


