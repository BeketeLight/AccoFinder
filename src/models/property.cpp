#include "property.h"

Property::Property(QObject *parent)
    :QObject(parent)
{

}

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
void Property::setId(const QString &id)
{
    m_id = id;
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

QString Property::getLocation() const
{
    return m_location;
}

void Property::setLocation(const QString &location)
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

void Property::setAgentId(const QString &agentId)
{
    m_agentId = agentId;
}



QString Property::getLandlordId() const
{
    return m_landlordId;
}


QDateTime Property::getCreatedAt() const
{
    return m_createdAt;
}

void Property::setCreatedAt(const QDateTime &createdAt)
{
    m_createdAt = createdAt;
}

void Property::setLandlordId(const QString &newLandlordId)
{
    m_landlordId = newLandlordId;
}

QString Property::firstName() const
{
    return m_firstName;
}

void Property::setFirstName(const QString &newFirstName)
{
    m_firstName = newFirstName;
}

QString Property::secondName() const
{
    return m_secondName;
}

void Property::setSecondName(const QString &newSecondName)
{
    m_secondName = newSecondName;
}


