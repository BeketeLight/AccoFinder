#include "roomdto.h"

RoomDto::RoomDto() {}

RoomDto::RoomDto(const QString &id,
                 const QString &propertyId,
                 const QString &type,
                 bool available)
    :m_id(id)
    ,m_propertyId(propertyId)
    ,m_type(type)
    ,m_available(available)
{

}

RoomDto RoomDto::fromJson(const QJsonObject &json)
{
    RoomDto dto;

    dto.m_id = json["id"].toString();

    dto.m_propertyId =json["propertyId"].toString();

    dto.m_available =json["available"].toBool();

    dto.m_type =json["type"].toString();

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

    json["available"] =
        m_available;

        return json;
}

QSharedPointer<Room> RoomDto::toDomainModel() const
{
    return QSharedPointer<Room>::create(m_id,m_propertyId,m_type,m_available);
}


