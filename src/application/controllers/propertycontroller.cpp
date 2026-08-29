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
    connect(m_propertyRepositoryImpl, &PropertyRepositoryImpl::propertyCreated,
            this, &PropertyController::propertyCreated);
    connect(m_propertyRepositoryImpl, &PropertyRepositoryImpl::propertyDeleted,
            this, &PropertyController::propertyDeleted);
    connect(m_propertyRepositoryImpl, &PropertyRepositoryImpl::propertyError,
            this, &PropertyController::propertyError);
}

void PropertyController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void PropertyController::getProperties(const QString &owner)
{
    setLoading(true);
    m_propertyRepositoryImpl->getProperties(owner);
}

void PropertyController::getPropertyById(const QString& houseId)
{
    if (houseId.isEmpty()) {
        emit propertyError("houseId cannot be empty");
        return;
    }
    setLoading(true);
    m_propertyRepositoryImpl->getPropertyById(houseId);
}

void PropertyController::getPropertiesByStatus(const QString &status)
{
    setLoading(true);
    m_propertyRepositoryImpl->getPropertiesByStatus(status);
}

void PropertyController::createProperty(const QString &title, const QString &description, double price,
                                        const QString &propertyType, const QString &district, const QString &village,
                                        const QStringList &amenities, const QString &landlord,
                                        const QString &landlordPhone, const QString &verificationStatus,
                                        bool isActive, const QJsonArray &rooms)
{
    if (title.isEmpty()) {
        emit propertyError("title cannot be empty");
        return;
    }
    setLoading(true);
    m_propertyRepositoryImpl->createProperty(title, description, price, propertyType, district, village,
                                             amenities, landlord, landlordPhone, verificationStatus, isActive, rooms);
}

void PropertyController::updateProperty(const QString& houseId,
                                        const QString& title,
                                        const QString& description,
                                        double price,
                                        const QString& district,
                                        const QString& village,
                                        const QStringList& amenities,
                                        const QString& landlord,
                                        const QString& landlordPhone,
                                        const QString& verificationStatus,
                                        bool isActive)
{
    if (houseId.isEmpty()) {
        emit propertyError("houseId cannot be empty");
        return;
    }
    if (title.isEmpty()) {
        emit propertyError("title cannot be empty");
        return;
    }
    setLoading(true);
    m_propertyRepositoryImpl->updateProperty(houseId, title, description, price, district, village,
                                             amenities, landlord, landlordPhone, verificationStatus, isActive);
}

void PropertyController::deleteProperty(const QString &houseId)
{
    if (houseId.isEmpty()) {
        emit propertyError("houseId cannot be empty");
        return;
    }
    setLoading(true);
    m_propertyRepositoryImpl->deleteProperty(houseId);
}

void PropertyController::attachMedia(const QString &houseId, const QStringList &mediaIds)
{
    if (houseId.isEmpty()) {
        emit propertyError("houseId cannot be empty");
        return;
    }
    m_propertyRepositoryImpl->attachMedia(houseId, mediaIds);
}
