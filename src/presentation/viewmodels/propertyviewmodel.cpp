#include "propertyviewmodel.h"

PropertyViewModel::PropertyViewModel(QObject *parent)
    : QObject{parent}
{
    connect(m_propertyController,&PropertyController::propertiesLoaded,
            this,&PropertyViewModel::onPropertiesLoaded);
    connect(m_propertyController,&PropertyController::propertyLoaded,
            this,&PropertyViewModel::onGetPropertyById);
    connect(m_propertyController,&PropertyController::propertyUpdated,
            this,&PropertyViewModel::onUpdateProperty);
}

void PropertyViewModel::getProperties()
{
    m_propertyController->getProperties();
    
}

void PropertyViewModel::getPropertyById(const QString &houseId)
{
     m_propertyController->getPropertyById(houseId);
}

void PropertyViewModel::updateProperty(int index, const QString &houseId, const QString &title, const QString &description, double price, const QString &costCategory)
{
    m_index = index;
    m_propertyController->updateProperty(houseId,title,description,price,costCategory);
    m_propertyController->getPropertyById(houseId);
}

void PropertyViewModel::onPropertiesLoaded(
    QList<Property*>& properties)
{
    m_propertyListModel->setProperties(properties);
}

void PropertyViewModel::onGetPropertyById(Property* property)
{
    m_propertyListModel->getPropertyById(property);
}

void PropertyViewModel::onUpdateProperty(Property* property)
{
    m_propertyListModel->updateProperty(m_index,property);
}
