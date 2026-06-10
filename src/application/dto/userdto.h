#ifndef USERDTO_H
#define USERDTO_H

#include <QJsonObject>
#include "models/user.h"

class UserDto
{
public:
    UserDto();
    UserDto(
        const QString& id,
        const QString& name,
        const QString& email,
        const QString& phone,
        const QString& role,
        const QDateTime& createdAt
        );

    // DTO Data
    QString id;
    QString name;
    QString email;
    QString phone;
    QString role;
    QDateTime createdAt;

    // JSON Conversion
    static UserDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    // Domain Conversion
    User* toDomainModel() const;
};

#endif // USERDTO_H
