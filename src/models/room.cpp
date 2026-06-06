#include "room.h"

Room::Room(QObject *parent)
    :QObject(parent)
{}
Room::Room(const QString& newId,
           const QString& newPropertyId,
           const QString& newType,
           bool newAvailable,
           QObject* parent)
    : QObject(parent)
    , id(newId)
    , propertyId(newPropertyId)
    , type(newType)
    , available(newAvailable)
{
    emit newRoomCreated();
}

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
    emit availabilityChanged();
}
