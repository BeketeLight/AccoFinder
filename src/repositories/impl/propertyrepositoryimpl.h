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
    void updateProperty(const QString& houseId,const QString& title,const QString& description,double price,const QString& costCategory) override;

private:

signals:
    void propertyLoaded(Property* property);
    void propertiesLoaded(const QList<Property*>& properties);
    void propertyUpdated(Property* properties);
    void propertyError(const QString& error);

};

#endif // PROPERTYREPOSITORYIMPL_H
