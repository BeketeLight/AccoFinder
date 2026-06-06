#include "property.h"

Property::Property(QObject *parent)
    :QObject(parent)
{}

Property::Property(const QString& newId,
                   const QString& newTitle,
                   const QString& newLocation,
                   double newPrice,
                   const QString& newDescription,
                   PropertyStatus  newStatus,
                   const QString& newAgentId,
                   const QString& newLandlordId,
                   const QDateTime& newCreatedAt,
                   QObject* parent)
    : QObject(parent)
    , id(newId)
    , title(newTitle)
    , location(newLocation)
    , price(newPrice)
    , description(newDescription)
    , status(newStatus)
    , agentId(newAgentId)
    , landlordId(newLandlordId)
    , createdAt(newCreatedAt)
{
    emit propertyCreated();
}

QString Property::getId() const
{
    return id;
}

void Property::setId(const QString &newId)
{
    id = newId;
    emit propertyUpdated();
}

QString Property::getTitle() const
{
    return title;
}

void Property::setTitle(const QString &newTitle)
{
    title = newTitle;
    emit propertyUpdated();
}

QString Property::getlocation() const
{
    return location;
}

void Property::setlocation(const QString &newlocation)
{
    location = newlocation;
    emit propertyUpdated();
}

double Property::getPrice() const
{
    return price;
}

void Property::setPrice(double newPrice)
{
    price = newPrice;
    emit propertyUpdated();
}

QString Property::getDescription() const
{
    return description;
}

void Property::setDescription(const QString &newDescription)
{
    description = newDescription;
    emit propertyUpdated();
}

PropertyStatus Property::getStatus() const
{
    return status;
}

void Property::setStatus(PropertyStatus newStatus)
{
    status = newStatus;
    emit propertyUpdated();
}

QString Property::getAgentId() const
{
    return agentId;
}

void Property::setAgentId(const QString &newAgentId)
{
    agentId = newAgentId;
    emit propertyUpdated();
}

QString Property::getLandlordId() const
{
    return landlordId;
}

void Property::setLandlordId(const QString &newLandlordId)
{
    landlordId = newLandlordId;
    emit propertyUpdated();
}

QDateTime Property::getCreatedAt() const
{
    return createdAt;
}

void Property::setCreatedAt(const QDateTime &newCreatedAt)
{
    createdAt = newCreatedAt;
    emit propertyUpdated();
}
