#ifndef IPROPERTYREPOSITORY_H
#define IPROPERTYREPOSITORY_H

#include <QObject>
#include <QStringList>
#include <QJsonArray>
#include "models/property.h"

class IPropertyRepository : public QObject
{
    Q_OBJECT
public:
    explicit IPropertyRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    virtual void getProperties(const QString& owner = QString()) = 0;
    // Listings that still need a decision are only returned when the request is
    // scoped to a single listing owner: GET /house-listing/ without `owner`
    // answers with VERIFIED listings only, while /dashboard/stats counts every
    // pending one. The admin verification queue therefore walks the owners and
    // asks for their unverified listings, delivered on its own signal so the
    // shared property list is never replaced by them.
    virtual void getPropertiesOwnedBy(const QString& ownerId) = 0;
    virtual void getPropertyById(const QString& houseId) = 0;
    virtual void getPropertiesByStatus(const QString& status) = 0;
    virtual void createProperty(const QString& title, const QString& description,
                                double price, const QString& propertyType, const QString& district, const QString& village,
                                const QStringList& amenities, const QString& landlord,
                                const QString& landlordPhone, const QString& verificationStatus,
                                bool isActive, const QJsonArray& rooms = QJsonArray()) = 0;
    virtual void updateProperty(const QString& houseId, const QString& title,
                                const QString& description, double price,
                                const QString& district, const QString& village,
                                const QStringList& amenities, const QString& landlord,
                                const QString& landlordPhone, const QString& verificationStatus,
                                bool isActive) = 0;
    virtual void updatePropertyStatus(const QString& houseId, const QString& status, const QString& reason = QString(),
                                      const QString& approvedById = QString(), const QString& approvedByName = QString()) = 0;
    // force skips the backend's active-booking guard. It is only ever set after
    // the user has explicitly confirmed the override dialog.
    virtual void deleteProperty(const QString& houseId, bool force = false) = 0;
    virtual void attachMedia(const QString& houseId, const QStringList& mediaIds) = 0;

    virtual ~IPropertyRepository() {}

};

#endif // IPROPERTYREPOSITORY_H
