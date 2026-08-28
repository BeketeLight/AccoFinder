#ifndef PROPERTY_H
#define PROPERTY_H

#include <QObject>
#include <QString>
#include <QStringList>
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
    void setLandlordId(const QString &newLandlordId);
    QDateTime getCreatedAt() const;
    void setCreatedAt(const QDateTime &createdAt);

    QString firstName() const;
    void setFirstName(const QString &newFirstName);
    QString secondName() const;
    void setSecondName(const QString &newSecondName);

    // Extended property schema (mirrors the Add-Property wizard)
    QString getDistrict() const;
    void setDistrict(const QString &district);
    QString getVillage() const;
    void setVillage(const QString &village);
    QStringList getAmenities() const;
    void setAmenities(const QStringList &amenities);
    QString getLandlordPhone() const;
    void setLandlordPhone(const QString &phone);
    QString getPropertyType() const;
    void setPropertyType(const QString &propertyType);
    bool isActive() const;
    void setActive(bool active);
    QString getVerificationStatus() const;
    void setVerificationStatus(const QString &status);

    int getRoomCount() const;
    void setRoomCount(int roomCount);

private:
    QString m_id;
    QString m_firstName;
    QString m_secondName;
    QString m_title;
    QString m_location;
    QString m_district;
    QString m_village;
    QStringList m_amenities;
    double m_price;
    QString m_description;
    PropertyStatus m_status;
    QString m_agentId;
    QString m_landlordId;
    QString m_landlordPhone;
    QString m_propertyType;
    QString m_verificationStatus;
    bool m_active = false;
    int m_roomCount = 0;
    QDateTime m_createdAt;
signals:
    void propertyVerfied();
    void propertyBooked();
    void propertyUpdated();
    void propertyCreated();
};

#endif // PROPERTY_H
