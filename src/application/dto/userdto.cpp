#include "userdto.h"

UserDto::UserDto()
{}

UserDto::UserDto(
    const QString& id,
    const QString& name,
    const QString& email,
    const QString& phone,
    const QString& role,
    const QDateTime& createdAt)
    : id(id),
    name(name),
    email(email),
    phone(phone),
    role(role),
    createdAt(createdAt)
{
}

UserDto UserDto::fromJson(
    const QJsonObject& json)
{
    UserDto dto;

    dto.id =
        json["id"].toString();

    dto.name =
        json["name"].toString();

    dto.email =
        json["email"].toString();

    dto.phone =
        json["phone"].toString();

    dto.role =
        json["role"].toString();

    dto.createdAt =
        QDateTime::fromString(
            json["createdAt"].toString(),
            Qt::ISODate
            );

    return dto;
}

QJsonObject UserDto::toJson() const
{
    QJsonObject json;

    json["id"] = id;
    json["name"] = name;
    json["email"] = email;
    json["phone"] = phone;
    json["role"] = role;
    json["createdAt"] =
        createdAt.toString(Qt::ISODate);

    return json;
}
User* UserDto::toDomainModel() const
{
    User* user = new User();

    user->setId(id);
    user->setName(name);
    user->setEmail(email);
    user->setPhone(phone);
    user->setCreatedAt(createdAt);

    return user;
}
