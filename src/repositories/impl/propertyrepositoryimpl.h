#ifndef PROPERTYREPOSITORYIMPL_H
#define PROPERTYREPOSITORYIMPL_H

#include "application/dto/propertydto.h"
#include "repositories/interfaces/IPropertyRepository.h"
#include "models/property.h"
#include <QStringList>
#include <QJsonArray>

class PropertyRepositoryImpl : public IPropertyRepository
{
    Q_OBJECT
public:
    explicit PropertyRepositoryImpl(QObject *parent = nullptr);
    void getProperties(const QString& owner = QString()) override;
    void getPropertyById(const QString& houseId) override;
    void getPropertiesByStatus(const QString& status) override;
    void createProperty(const QString& title, const QString& description,
                        double price, const QString& propertyType, const QString& district, const QString& village,
                        const QStringList& amenities, const QString& landlord,
                        const QString& landlordPhone, const QString& verificationStatus,
                        bool isActive, const QJsonArray& rooms) override;
    void updateProperty(const QString& houseId, const QString& title,
                        const QString& description, double price,
                        const QString& district, const QString& village,
                        const QStringList& amenities, const QString& landlord,
                        const QString& landlordPhone, const QString& verificationStatus,
                        bool isActive) override;
    void updatePropertyStatus(const QString& houseId, const QString& status) override;
    void deleteProperty(const QString& houseId) override;
    void attachMedia(const QString& houseId, const QStringList& mediaIds) override;

private:

signals:
    void propertyLoaded(Property* property);
    void propertiesLoaded(QList<Property*>& properties);
    void propertyUpdated(Property* properties);
    void propertyCreated(Property* property);
    void propertyDeleted(const QString& houseId);
    void propertyError(const QString& error);

};

#endif // PROPERTYREPOSITORYIMPL_H
