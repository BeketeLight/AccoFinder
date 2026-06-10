#ifndef PROPERTYCONTROLLER_H
#define PROPERTYCONTROLLER_H

#include <QObject>
#include "models/property.h"
#include "repositories/impl/propertyrepositoryimpl.h"

class PropertyController : public QObject
{
    Q_OBJECT
public:
    PropertyController();
    Property* getProperties();
    Property* getPropertyById();
    Property* updateProperty();
private:
    PropertyRepositoryImpl *m_propertyRepositoryImpl = new PropertyRepositoryImpl();
};

#endif // PROPERTYCONTROLLER_H
