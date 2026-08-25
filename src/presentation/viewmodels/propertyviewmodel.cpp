#include "propertyviewmodel.h"

PropertyViewModel::PropertyViewModel(QObject *parent)
    : QObject{parent},
      m_propertyListModel(new PropertyListModel(this)),
      m_propertyController(new PropertyController(this))
{
    connect(m_propertyController, &PropertyController::propertiesLoaded,
            this, &PropertyViewModel::onPropertiesLoaded);
    connect(m_propertyController, &PropertyController::propertyLoaded,
            this, &PropertyViewModel::onGetPropertyById);
    connect(m_propertyController, &PropertyController::propertyUpdated,
            this, &PropertyViewModel::onUpdateProperty);
    connect(m_propertyController, &PropertyController::propertyError,
            this, &PropertyViewModel::onPropertyError);
}

void PropertyViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void PropertyViewModel::getProperties()
{
    setLoading(true);
    m_propertyController->getProperties();
}

void PropertyViewModel::getPropertyById(const QString &houseId)
{
    setLoading(true);
    m_propertyController->getPropertyById(houseId);
}

void PropertyViewModel::updateProperty(int index, const QString &houseId, const QString &title, const QString &description, double price, const QString &costCategory)
{
    m_index = index;
    setLoading(true);
    m_propertyController->updateProperty(houseId, title, description, price, costCategory);
}

void PropertyViewModel::createProperty(const QString &title, const QString &description, double price, const QString &costCategory)
{
    setLoading(true);
    m_propertyController->createProperty(title, description, price, costCategory);
}

void PropertyViewModel::deleteProperty(const QString &houseId)
{
    setLoading(true);
    m_propertyController->deleteProperty(houseId);
}

void PropertyViewModel::onPropertiesLoaded(QList<Property*> &properties)
{
    setLoading(false);
    m_propertyListModel->setProperties(properties);
}

void PropertyViewModel::onGetPropertyById(Property *property)
{
    setLoading(false);
    m_propertyListModel->getPropertyById(property);
}

void PropertyViewModel::onUpdateProperty(Property *property)
{
    setLoading(false);
    if (m_index >= 0)
        m_propertyListModel->updateProperty(m_index, property);
}

void PropertyViewModel::onPropertyError(const QString &error)
{
    setLoading(false);
    emit propertyError(error);
}
