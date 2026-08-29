#include "roomdto.h"

RoomDto::RoomDto() {}

RoomDto::RoomDto(const QString &id,
                 const QString &propertyId,
                 const QString &type,
                 double price,
                 bool available)
    :m_id(id)
    ,m_propertyId(propertyId)
    ,m_type(type)
    ,m_price(price)
    ,m_available(available)
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

    dto.m_type = json["type"].toString();

    dto.m_price = static_cast<double>(json["price"].toDouble());

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

    json["price"] = m_price;

    json["available"] =
        m_available;

        return json;
}

QSharedPointer<Room> RoomDto::toDomainModel() const
{
    return QSharedPointer<Room>::create(m_id,m_propertyId,m_type,m_price,m_available);
}


