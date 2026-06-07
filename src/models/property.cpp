#include "property.h"

Property::Property(const QString& id,
                   const QString& title,
                   const QString& location,
                   const QString& agentId,
                   const QString& landlordId,
                   const QDateTime& createdAt,
                   QObject* parent)
    : QObject(parent)
    , m_id(id)
    , m_title(title)
    , m_location(location)
    , m_agentId(agentId)
    , m_landlordId(landlordId)
    , m_createdAt(createdAt)
{
    emit propertyCreated();
}

QString Property::getId() const
{
    return m_id;
}


QString Property::getTitle() const
{
    return m_title;
}

void Property::setTitle(const QString &title)
{
    m_title = title;
    emit propertyUpdated();
}

QString Property::getlocation() const
{
    return m_location;
}

void Property::setlocation(const QString &location)
{
    m_location = location;
    emit propertyUpdated();
}

double Property::getPrice() const
{
    return m_price;
}

void Property::setPrice(double price)
{
    m_price = price;
    emit propertyUpdated();
}

QString Property::getDescription() const
{
    return m_description;
}

void Property::setDescription(const QString &description)
{
    m_description = description;
    emit propertyUpdated();
}

PropertyStatus Property::getStatus() const
{
    return m_status;
}

void Property::setStatus(PropertyStatus status)
{
    status = status;
    emit propertyUpdated();
}

QString Property::getAgentId() const
{
    return m_agentId;
}



QString Property::getLandlordId() const
{
    return m_landlordId;
}


QDateTime Property::getCreatedAt() const
{
    return m_createdAt;
}
