
#ifndef PROPERTYDTO_H
#define PROPERTYDTO_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include "models/property.h"

class PropertyDto
{
public:
   PropertyDto();

    PropertyDto(
        const QString& id,
        const QString& title,
        const QString& location,
        double price,
        const QString& description,
        const QString& status,
        const QString& agentId,
        const QString& landlordId,
        const QString& costCategory,
        const QDateTime& createdAt
        );

    PropertyDto(
        const QString& title,
        const QString& description,
        double price,
        const QString& costCategory
        );

    QJsonObject toCreateJson() const;
    QJsonObject toUpdateJson() const;

    // DTO Data
    QString id;
    QString title;
    QString location;
    double price;
    QString description;
    QString status;
    QString agentId;
    QString landlordId;
    const QString costCategory;
    QDateTime createdAt;

    // JSON Conversion
    static PropertyDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    // Domain Conversion
    Property* toDomainModel() const;
    ~PropertyDto();
};

#endif // PROPERTYDTO_H
