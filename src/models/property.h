#ifndef PROPERTY_H
#define PROPERTY_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include "core/utils/EPropertyStatus.h"

class Property : public QObject
{
    Q_OBJECT
public:
    explicit Property(QObject *parent = nullptr);
    QString getId() const;
    void setId(const QString &newId);
    QString getTitle() const;
    void setTitle(const QString &newTitle);
    QString getClocation() const;
    void setClocation(const QString &newClocation);
    double getPrice() const;
    void setPrice(double newPrice);
    QString getDescription() const;
    void setDescription(const QString &newDescription);
    PropertyStatus getStatus() const;
    void setStatus(PropertyStatus newStatus);
    QString getAngentId() const;
    void setAngentId(const QString &newAngentId);
    QString getLandlordId() const;
    void setLandlordId(const QString &newLandlordId);
    QDateTime getCreatedAt() const;
    void setCreatedAt(const QDateTime &newCreatedAt);

private:
    QString id;
    QString title;
    QString clocation;
    double price;
    QString description;
    PropertyStatus status;
    QString angentId;
    QString landlordId;
    QDateTime createdAt;
signals:
    void propertyVerfied();
    void propertyBooked();
    void propertyUpdated();
};

#endif // PROPERTY_H
