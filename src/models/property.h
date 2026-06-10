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
    explicit Property(QObject* parent = nullptr);
    explicit Property(const QString& id,
             const QString& title,
             const QString& location,
             const QString& agentId,
             const QString& landlordId,
             const QDateTime& createdAt = QDateTime(),
             QObject* parent = nullptr);
    QString getId() const;
    void setId(const QString &idd);
    QString getTitle() const;
    void setTitle(const QString &title);
    QString getLocation() const;
    void setLocation(const QString &location);
    double getPrice() const;
    void setPrice(double price);
    QString getDescription() const;
    void setDescription(const QString &description);
    PropertyStatus getStatus() const;
    void setStatus(PropertyStatus status);
    QString getAgentId() const;
    void setAgentId(const QString &agentId);
    QString getLandlordId() const;
    QDateTime getCreatedAt() const;
    void setCreatedAt(const QDateTime &createdAt);




    void setLandlordId(const QString &newLandlordId);

private:
    QString m_id;
    QString m_title;
    QString m_location;
    double m_price;
    QString m_description;
    PropertyStatus m_status;
    QString m_agentId;
    QString m_landlordId;
    QDateTime m_createdAt;
signals:
    void propertyVerfied();
    void propertyBooked();
    void propertyUpdated();
    void propertyCreated();
};

#endif // PROPERTY_H
