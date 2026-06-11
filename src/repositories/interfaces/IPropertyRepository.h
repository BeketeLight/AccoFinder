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
    virtual void getProperties() = 0;
    virtual void getPropertyById(const QString& houseId) = 0;
    virtual void updateProperty(const QString& houseId,const QString& title,const QString& description,double price,const QString& costCategory) = 0;

    virtual ~IPropertyRepository() {}

};

#endif // IPROPERTYREPOSITORY_H
