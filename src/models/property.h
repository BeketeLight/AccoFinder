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
    Property(const QString& newId,
             const QString& newTitle,
             const QString& newLocation,
             double newPrice,
             const QString& newDescription,
             PropertyStatus newStatus,
             const QString& newAgentId,
             const QString& newLandlordId,
             const QDateTime& newCreatedAt = QDateTime(),
             QObject* parent = nullptr);
    QString getId() const;
    void setId(const QString &newId);
    QString getTitle() const;
    void setTitle(const QString &newTitle);
    QString getlocation() const;
    void setlocation(const QString &newlocation);
    double getPrice() const;
    void setPrice(double newPrice);
    QString getDescription() const;
    void setDescription(const QString &newDescription);
    PropertyStatus getStatus() const;
    void setStatus(PropertyStatus newStatus);
    QString getAgentId() const;
    void setAgentId(const QString &newAgentId);
    QString getLandlordId() const;
    void setLandlordId(const QString &newLandlordId);
    QDateTime getCreatedAt() const;
    void setCreatedAt(const QDateTime &newCreatedAt);

private:
    QString id;
    QString title;
    QString location;
    double price;
    QString description;
    PropertyStatus status;
    QString agentId;
    QString landlordId;
    QDateTime createdAt;
signals:
    void propertyVerfied();
    void propertyBooked();
    void propertyUpdated();
    void propertyCreated();
};

#endif // PROPERTY_H
