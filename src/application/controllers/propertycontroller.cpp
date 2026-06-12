#include "propertycontroller.h"

PropertyController::PropertyController(QObject *parent)
    : QObject(parent),
      m_propertyRepositoryImpl(new PropertyRepositoryImpl(this))
{
    connect(m_propertyRepositoryImpl, &PropertyRepositoryImpl::propertiesLoaded,
            this, &PropertyController::propertiesLoaded);

    connect(m_propertyRepositoryImpl, &PropertyRepositoryImpl::propertyLoaded,
            this, &PropertyController::propertyLoaded);

    connect(m_propertyRepositoryImpl, &PropertyRepositoryImpl::propertyUpdated,
            this, &PropertyController::propertyUpdated);

    connect(m_propertyRepositoryImpl, &PropertyRepositoryImpl::propertyError,
            this, &PropertyController::propertyError);
}

void PropertyController::getProperties()
{
    m_propertyRepositoryImpl->getProperties();
}

void PropertyController::getPropertyById(const QString& houseId)
{
    if (houseId.isEmpty()) {
        emit propertyError("houseId cannot be empty");
        return;
    }
    m_propertyRepositoryImpl->getPropertyById(houseId);
}

void PropertyController::updateProperty(const QString& houseId,
                                        const QString& title,
                                        const QString& description,
                                        double price,
                                        const QString& costCategory)
{
    if (houseId.isEmpty()) {
        emit propertyError("houseId cannot be empty");
        return;
    }
    if (title.isEmpty()) {
        emit propertyError("title cannot be empty");
        return;
    }
    if (price <= 0) {
        emit propertyError("price must be greater than 0");
        return;
    }
    if (costCategory != "Low_Cost" && costCategory != "Medium_Cost" && costCategory != "High_Cost") {
        emit propertyError("invalid costCategory");
        return;
    }

    m_propertyRepositoryImpl->updateProperty(houseId, title, description, price, costCategory);
}
