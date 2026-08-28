#include "propertydto.h"
#include <QJsonArray>

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

PropertyDto::PropertyDto(
    const QString& title,
    const QString& description,
    double price,
    const QString& propertyType,
    const QString& district,
    const QString& village,
    const QStringList& amenities,
    const QString& landlord,
    const QString& landlordPhone,
    const QString& verificationStatus,
    bool isActive,
    const QJsonArray& rooms)
    : title(title),
      description(description),
      propertyType(propertyType),
      district(district),
      village(village),
      amenities(amenities),
      price(price),
      verificationStatus(verificationStatus),
      isActive(isActive),
      rooms(rooms),
      costCategory(QString()),
      createdAt(QDateTime())
{
    this->landlordId = landlord;
    this->landlordPhone = landlordPhone;
}

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

    // Extended schema
    const QJsonObject addr = json["physicalAddress"].toObject();
    dto.district = addr["district"].toString();
    dto.village = addr["village"].toString();

    QStringList amens;
    const QJsonArray amensArray = json["amenities"].toArray();
    for (const QJsonValue& v : amensArray)
        amens.append(v.toString());
    dto.amenities = amens;

    dto.landlordId = json["landlord"].toString();
    dto.landlordPhone = json["landlordPhone"].toString();
    dto.propertyType = json["propertyType"].toString();
    dto.verificationStatus = json["verificationStatus"].toString();
    dto.isActive = json["isActive"].toBool(true);
    dto.rooms = json["rooms"].toArray();

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

    QJsonObject address;
    address["district"] = district;
    address["village"] = village;
    json["physicalAddress"] = address;

    QJsonArray amens;
    for (const QString& a : amenities)
        amens.append(a);
    json["amenities"] = amens;

    json["landlord"] = landlordId;
    json["landlordPhone"] = landlordPhone;
    json["propertyType"] = propertyType;
    json["verificationStatus"] = verificationStatus;
    json["isActive"] = isActive;

    if (!rooms.isEmpty())
        json["rooms"] = rooms;

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

    // Extended schema
    property->setDistrict(district);
    property->setVillage(village);
    property->setAmenities(amenities);
    property->setLandlordPhone(landlordPhone);
    property->setPropertyType(propertyType);
    property->setVerificationStatus(verificationStatus);
    property->setActive(isActive);
    property->setRoomCount(rooms.size());

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

    if(!costCategory.isNull() && !costCategory.isEmpty())
        json["costCategory"] = costCategory;

    if(price)
        json["price"] = price;

    if(!district.isEmpty() || !village.isEmpty()) {
        QJsonObject address;
        if(!district.isEmpty())
            address["district"] = district;
        if(!village.isEmpty())
            address["village"] = village;
        json["physicalAddress"] = address;
    }

    if(!amenities.isEmpty()) {
        QJsonArray amens;
        for (const QString& a : amenities)
            amens.append(a);
        json["amenities"] = amens;
    }

    if(!landlordId.isEmpty())
        json["landlord"] = landlordId;
    if(!landlordPhone.isEmpty())
        json["landlordPhone"] = landlordPhone;
    if(!verificationStatus.isEmpty())
        json["verificationStatus"] = verificationStatus;
    json["isActive"] = isActive;

    return json;
}

QJsonObject PropertyDto::toCreateJson() const
{
    QJsonObject json;
    json["title"] = title;
    json["description"] = description;
    json["price"] = price;

    if (!propertyType.isEmpty())
        json["propertyType"] = propertyType;

    QJsonObject address;
    address["district"] = district;
    address["village"] = village;
    json["physicalAddress"] = address;

    QJsonArray amens;
    for (const QString& a : amenities)
        amens.append(a);
    json["amenities"] = amens;

    json["landlord"] = landlordId;
    json["landlordPhone"] = landlordPhone;
    json["verificationStatus"] = verificationStatus;
    json["isActive"] = isActive;
    json["costCategory"] = costCategory.isNull() ? QString() : costCategory;

    // Inline rooms create the rooms atomically with the property
    if (!rooms.isEmpty())
        json["rooms"] = rooms;

    return json;
}