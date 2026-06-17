#include "propertydto.h"

PropertyDto::PropertyDto()
{

}

PropertyDto::PropertyDto(
    const QString& id,
    const QString firstname,
    const QString secondName,
    const QString& title,
    const QString& location,
    double price,
    const QString& description,
    const QString& status,
    const QString& agentId,
    const QString& landlordId,
    const QString& costCategory,
    const QDateTime& createdAt)
    : id(id),
    firstname(firstname),
    secondName(secondName),
    title(title),
    location(location),
    price(price),
    description(description),
    status(status),
    agentId(agentId),
    landlordId(landlordId),
    costCategory(costCategory),
    createdAt(createdAt)
{
}


PropertyDto::PropertyDto(
    const QString& title,
    const QString& description,
    double price,
    const QString& costCategory
    )
    :title(title),
    description(description),
    price(price),
    costCategory(costCategory)
{}

PropertyDto PropertyDto::fromJson(
    const QJsonObject& json)
{
    PropertyDto dto;

    dto.id =
        json["id"].toString();
    dto.firstname =
        json["firstName"].toString();
    dto.secondName =
        json["secondName"].toString();
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
    json["firstName"] = firstname;
    json["secondName"] = secondName;
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
    property->setFirstName(firstname);
    property->setSecondName(secondName);
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

PropertyDto::~PropertyDto()
{

}

QJsonObject PropertyDto::toUpdateJson() const
{
    QJsonObject json;

    if(!title.isEmpty())
        json["title"] = title;

    if(!description.isEmpty())
        json["description"] = description;

    if(!costCategory.isEmpty())
        json["costCategory"] = costCategory;

    if(price)
        json["price"] = price;

    return json;
}