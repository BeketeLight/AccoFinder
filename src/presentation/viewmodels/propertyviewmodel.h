#ifndef PROPERTYVIEWMODEL_H
#define PROPERTYVIEWMODEL_H

#include <QObject>
#include <QSharedPointer>
#include "application/controllers/propertycontroller.h"
#include "presentation/models/propertylistmodel.h"

class PropertyViewModel : public QObject
{
    Q_OBJECT
public:
    explicit PropertyViewModel(QObject *parent = nullptr);
    Q_INVOKABLE void getProperties();
    Q_INVOKABLE void getPropertyById(const QString& houseId);
    Q_INVOKABLE void updateProperty(int index,
                                    const QString& houseId,
                                    const QString& title,
                                    const QString& description,
                                    double price,
                                    const QString& costCategory);
    void setPropertyListModel(PropertyListModel *newPropertyListModel);
    void setPropertyController(PropertyController *newPropertyController);

private:
    int m_index;
   PropertyListModel* m_propertyListModel = nullptr;
   PropertyController* m_propertyController = nullptr;

private slots:
   void onPropertiesLoaded(
       QList<Property*>& properties
       );
   void onGetPropertyById(Property* property);
   void onUpdateProperty(Property* property);


signals:
};

#endif // PROPERTYVIEWMODEL_H
