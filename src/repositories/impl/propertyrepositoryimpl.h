#ifndef PROPERTYREPOSITORYIMPL_H
#define PROPERTYREPOSITORYIMPL_H

#include "application/dto/propertydto.h"
#include "repositories/interfaces/IPropertyRepository.h"
#include "models/property.h"

class PropertyRepositoryImpl : public IPropertyRepository
{
    Q_OBJECT
public:
    explicit PropertyRepositoryImpl(QObject *parent = nullptr);
    void getProperties() override;
    void getPropertyById(const QString& houseId) override;
    void getPropertiesByStatus(const QString& status) override;
    void createProperty(const QString& title, const QString& description,
                        double price, const QString& costCategory) override;
    void updateProperty(const QString& houseId,const QString& title,const QString& description,double price,const QString& costCategory) override;
    void deleteProperty(const QString& houseId) override;

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
