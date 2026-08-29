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
    virtual void deleteProperty(const QString& houseId) = 0;
    virtual void attachMedia(const QString& houseId, const QStringList& mediaIds) = 0;

    virtual ~IPropertyRepository() {}

};

#endif // IPROPERTYREPOSITORY_H
