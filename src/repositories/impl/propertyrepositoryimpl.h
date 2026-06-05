#ifndef PROPERTYREPOSITORYIMPL_H
#define PROPERTYREPOSITORYIMPL_H

#include "repositories/interfaces/IPropertyRepository.h"
#include "models/property.h"

class PropertyRepositoryImpl : public IPropertyRepository
{
public:
    PropertyRepositoryImpl();
    Property* getProperties() override;
    Property* getPropertyById() override;
    Property* updateProperty() override;
private:
    Property* property = new Property;
};

#endif // PROPERTYREPOSITORYIMPL_H
