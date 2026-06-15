#ifndef PROPERTYCONTROLLER_H
#define PROPERTYCONTROLLER_H

#include <QObject>
#include <QList>
#include "models/property.h"
#include "repositories/impl/propertyrepositoryimpl.h"

class PropertyController : public QObject
{
    Q_OBJECT
public:
    explicit PropertyController(QObject *parent = nullptr);

    Q_INVOKABLE void getProperties();
    Q_INVOKABLE void getPropertyById(const QString& houseId);
    Q_INVOKABLE void updateProperty(const QString& houseId,
                                    const QString& title,
                                    const QString& description,
                                    double price,
                                   const QString& costCategory);

signals:
    void propertiesLoaded(QList<Property*>& properties);
    void propertyLoaded(Property* property);
    void propertyUpdated(Property* property);
    void propertyError(const QString& error);

private:
    PropertyRepositoryImpl *m_propertyRepositoryImpl;
};

#endif // PROPERTYCONTROLLER_H
