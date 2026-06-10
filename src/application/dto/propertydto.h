
#ifndef PROPERTYDTO_H
#define PROPERTYDTO_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include "models/property.h"

class PropertyDto
{
public:
    PropertyDto() = default;

    PropertyDto(
        const QString& id,
        const QString& title,
        const QString& location,
        double price,
        const QString& description,
        const QString& status,
        const QString& agentId,
        const QString& landlordId,
        const QDateTime& createdAt
        );

    // DTO Data
    QString id;
    QString title;
    QString location;
    double price;
    QString description;
    QString status;
    QString agentId;
    QString landlordId;
    QDateTime createdAt;

    // JSON Conversion
    static PropertyDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    // Domain Conversion
    Property* toDomainModel() const;
};

#endif // PROPERTYDTO_H
