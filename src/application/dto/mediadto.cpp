#include "mediadto.h"

MediaDto::MediaDto()
    : m_isPrimary(false)
{
}

MediaDto::MediaDto(const QString &id,
                   const QString &propertyId,
                   const QString &url,
                   const QString &type,
                   bool isPrimary,
                   const QString &roomId)
    : m_id(id)
    , m_propertyId(propertyId)
    , m_url(url)
    , m_type(type)
    , m_isPrimary(isPrimary)
    , m_roomId(roomId)
{
}

MediaDto MediaDto::fromJson(const QJsonObject &json)
{
    MediaDto dto;

    // The backend returns the media id under "_id" (Mongoose/Mongo ObjectId),
    // matching the convention used by the other DTOs in this codebase.
    dto.m_id = json["_id"].toString();
    dto.m_propertyId = json["propertyId"].toString();

    // url mirrors the UI "path" of an uploaded photo
    dto.m_url = json["url"].toString();
    dto.m_type = json["type"].toString();
    dto.m_isPrimary = json["isPrimary"].toBool(false);
    dto.m_roomId = json["roomId"].toString();

    return dto;
}

QJsonObject MediaDto::toJson() const
{
    QJsonObject json;

    json["id"] = m_id;
    json["propertyId"] = m_propertyId;
    json["url"] = m_url;
    json["type"] = m_type;
    json["isPrimary"] = m_isPrimary;
    json["roomId"] = m_roomId;

    return json;
}

QJsonObject MediaDto::toCreateJson() const
{
    QJsonObject json;

    json["propertyId"] = m_propertyId;
    json["url"] = m_url;
    json["type"] = m_type;
    json["isPrimary"] = m_isPrimary;
    json["roomId"] = m_roomId;

    return json;
}

QSharedPointer<Media> MediaDto::toDomainModel() const
{
    return QSharedPointer<Media>::create(m_id, m_propertyId, m_url, m_type,
                                         m_isPrimary, m_roomId);
}
