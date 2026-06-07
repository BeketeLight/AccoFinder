#include "room.h"

Room::Room(const QString &id,
           const QString &propertyId,
           const QString &agentId,
           const QString &landlordId,
           const QString &type,
           bool available,
           const QString& title,
           const QString &location,
           const QDateTime &createdAt,
           QObject *parent)
    :Property(id,title,location,agentId,landlordId,createdAt,parent)
    ,m_id(id)
    ,m_propertyId(propertyId)
    ,m_type(type)
    ,m_available(available)
{
    emit newRoomCreated();
}

QString Room::getId() const
{
    return m_id;
}


QString Room::getPropertyId() const
{
    return m_propertyId;
}


QString Room::getType() const
{
    return m_type;
}

void Room::setType(const QString &type)
{
    m_type = type;
}

bool Room::getAvailable() const
{
    return m_available;
}

void Room::setAvailable(bool available)
{
    m_available = available;
    emit availabilityChanged();
}
