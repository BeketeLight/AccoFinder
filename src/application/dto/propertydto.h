
#ifndef PROPERTYDTO_H
#define PROPERTYDTO_H

#include <QString>
#include <QStringList>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonArray>
#include "models/property.h"

class PropertyDto
{
public:
   PropertyDto();

    PropertyDto(
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
        const QDateTime& createdAt
        );

    PropertyDto(
        const QString& title,
        const QString& description,
        double price,
        const QString& costCategory
        );

    // Full-schema create constructor mirroring the Add-Property wizard.
    // `rooms` carries inline room docs (type, price, available) so a property
    // and its rooms are created atomically in one request.
    PropertyDto(
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
        const QJsonArray& rooms = QJsonArray()
        );

    QJsonObject toCreateJson() const;
    QJsonObject toUpdateJson() const;

    // DTO Data
    QString id;
    QString firstname;
    QString secondName;
    QString title;
    QString location;
    QString district;
    QString village;
    QStringList amenities;
    double price;
    QString description;
    QString status;
    QString agentId;
    QString agentPhone;
    QString landlordId;
    QString landlordPhone;
    QString propertyType;
    QString verificationStatus;
    QJsonArray rooms;
    bool isActive = false;
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
