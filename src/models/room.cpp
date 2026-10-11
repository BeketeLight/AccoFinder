#include "room.h"

Room::Room()
{

}

Room::Room(const QString &id,
           const QString &propertyId,
           const QString &type,
           double price,
           bool available,
           bool holdActive,
           const QDateTime &holdExpiresAt,
           QObject *parent)
    :m_id(id)
    ,QObject(parent)
    ,m_propertyId(propertyId)
    ,m_type(type)
    ,m_price(price)
    ,m_available(available)
    ,m_holdActive(holdActive)
    ,m_holdExpiresAt(holdExpiresAt)
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

double Room::getPrice() const
{
    return m_price;
}

void Room::setPrice(double price)
{
    m_price = price;
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

bool Room::getHoldActive() const
{
    return m_holdActive;
}

void Room::setHoldActive(bool holdActive)
{
    if (m_holdActive == holdActive)
        return;
    m_holdActive = holdActive;
    emit holdStateChanged();
}

QDateTime Room::getHoldExpiresAt() const
{
    return m_holdExpiresAt;
}

void Room::setHoldExpiresAt(const QDateTime &holdExpiresAt)
{
    if (m_holdExpiresAt == holdExpiresAt)
        return;
    m_holdExpiresAt = holdExpiresAt;
    emit holdStateChanged();
}

QString Room::getStatusLabel() const
{
    if (!m_available)
        return QStringLiteral("Booked");
    if (m_holdActive)
        return QStringLiteral("On hold");
    return QStringLiteral("Available");
}
