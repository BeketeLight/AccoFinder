#include "propertydto.h"

PropertyDto::PropertyDto(
    const QString& id,
    const QString& title,
    const QString& location,
    double price,
    const QString& description,
    const QString& status,
    const QString& agentId,
    const QString& landlordId,
    const QDateTime& createdAt)
    : id(id),
    title(title),
    location(location),
    price(price),
    description(description),
    status(status),
    agentId(agentId),
    landlordId(landlordId),
    createdAt(createdAt)
{
}

PropertyDto PropertyDto::fromJson(
    const QJsonObject& json)
{
    PropertyDto dto;

    dto.id =
        json["id"].toString();

    dto.title =
        json["title"].toString();

    dto.location =
        json["location"].toString();

    dto.price =
        json["price"].toDouble();

    dto.description =
        json["description"].toString();

    dto.status =
        json["status"].toString();

    dto.agentId =
        json["agentId"].toString();

    dto.landlordId =
        json["landlordId"].toString();

    dto.createdAt =
        QDateTime::fromString(
            json["createdAt"].toString(),
            Qt::ISODate);

    return dto;
}

QJsonObject PropertyDto::toJson() const
{
    QJsonObject json;

    json["id"] = id;
    json["title"] = title;
    json["location"] = location;
    json["price"] = price;
    json["description"] = description;
    json["status"] = status;
    json["agentId"] = agentId;
    json["landlordId"] = landlordId;
    json["createdAt"] =
        createdAt.toString(Qt::ISODate);

    return json;
}

Property* PropertyDto::toDomainModel() const
{
    Property* property = new Property();

    property->setId(id);
    property->setTitle(title);
    property->setLocation(location);
    property->setPrice(price);
    property->setDescription(description);

    // Assuming status is an enum
    // property->setStatus(...);

    property->setAgentId(agentId);
    property->setLandlordId(landlordId);
    property->setCreatedAt(createdAt);

    return property;
}