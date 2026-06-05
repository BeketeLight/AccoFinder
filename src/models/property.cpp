#include "property.h"

Property::Property(QObject *parent)
    :QObject(parent)
{}

QString Property::getId() const
{
    return id;
}

void Property::setId(const QString &newId)
{
    id = newId;
}

QString Property::getTitle() const
{
    return title;
}

void Property::setTitle(const QString &newTitle)
{
    title = newTitle;
}

QString Property::getClocation() const
{
    return clocation;
}

void Property::setClocation(const QString &newClocation)
{
    clocation = newClocation;
}

double Property::getPrice() const
{
    return price;
}

void Property::setPrice(double newPrice)
{
    price = newPrice;
}

QString Property::getDescription() const
{
    return description;
}

void Property::setDescription(const QString &newDescription)
{
    description = newDescription;
}

PropertyStatus Property::getStatus() const
{
    return status;
}

void Property::setStatus(PropertyStatus newStatus)
{
    status = newStatus;
}

QString Property::getAngentId() const
{
    return angentId;
}

void Property::setAngentId(const QString &newAngentId)
{
    angentId = newAngentId;
}

QString Property::getLandlordId() const
{
    return landlordId;
}

void Property::setLandlordId(const QString &newLandlordId)
{
    landlordId = newLandlordId;
}

QDateTime Property::getCreatedAt() const
{
    return createdAt;
}

void Property::setCreatedAt(const QDateTime &newCreatedAt)
{
    createdAt = newCreatedAt;
}
