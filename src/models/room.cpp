#include "room.h"

Room::Room(QObject *parent)
    :QObject(parent)
{}

QString Room::getId() const
{
    return id;
}

void Room::setId(const QString &newId)
{
    id = newId;
}

QString Room::getPropertyId() const
{
    return propertyId;
}

void Room::setPropertyId(const QString &newPropertyId)
{
    propertyId = newPropertyId;
}

QString Room::getType() const
{
    return type;
}

void Room::setType(const QString &newType)
{
    type = newType;
}

bool Room::getAvailable() const
{
    return available;
}

void Room::setAvailable(bool newAvailable)
{
    available = newAvailable;
}
