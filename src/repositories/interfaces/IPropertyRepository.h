#ifndef IPROPERTYREPOSITORY_H
#define IPROPERTYREPOSITORY_H

#include <QObject>
#include "models/property.h"

class IPropertyRepository : public QObject
{
    Q_OBJECT
public:
    explicit IPropertyRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    virtual Property* getProperties() = 0;
    virtual Property* getPropertyById() = 0;
    virtual Property* updateProperty() = 0;

    virtual ~IPropertyRepository() {}
private:
signals:
};

#endif // IPROPERTYREPOSITORY_H
