#include "media.h"

Media::Media()
    : m_isPrimary(false)
{
}

Media::Media(const QString &id,
             const QString &propertyId,
             const QString &url,
             const QString &type,
             bool isPrimary,
             const QString &roomId,
             QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_propertyId(propertyId)
    , m_url(url)
    , m_type(type)
    , m_isPrimary(isPrimary)
    , m_roomId(roomId)
{
    emit mediaAdded();
}

QString Media::getId() const
{
    return m_id;
}

void Media::setId(const QString &id)
{
    m_id = id;
}

QString Media::getPropertyId() const
{
    return m_propertyId;
}

void Media::setPropertyId(const QString &propertyId)
{
    m_propertyId = propertyId;
}

QString Media::getUrl() const
{
    return m_url;
}

void Media::setUrl(const QString &url)
{
    m_url = url;
}

QString Media::getType() const
{
    return m_type;
}

void Media::setType(const QString &type)
{
    m_type = type;
}

bool Media::getIsPrimary() const
{
    return m_isPrimary;
}

void Media::setIsPrimary(bool isPrimary)
{
    m_isPrimary = isPrimary;
}

QString Media::getRoomId() const
{
    return m_roomId;
}

void Media::setRoomId(const QString &roomId)
{
    m_roomId = roomId;
}
