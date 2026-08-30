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
    connect(m_propertyController, &PropertyController::propertyCreated,
            this, &PropertyViewModel::onCreateProperty);
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

int PropertyViewModel::pendingPropertiesCount() const
{
    int count = 0;
    const QVariantList list = propertiesForView();
    for (const QVariant& v : list) {
        const QVariantMap row = v.toMap();
        const QString status = row.value("verificationStatus").toString().toUpper();
        if (status != "VERIFIED" && status != "REJECTED")
            ++count;
    }
    return count;
}

int PropertyViewModel::verifiedPropertiesCount() const
{
    int count = 0;
    const QVariantList list = propertiesForView();
    for (const QVariant& v : list) {
        const QVariantMap row = v.toMap();
        if (row.value("verificationStatus").toString().toUpper() == "VERIFIED")
            ++count;
    }
    return count;
}

void PropertyViewModel::getProperties(const QString &owner)
{
    setLoading(true);
    m_propertyController->getProperties(owner);
}

QVariantList PropertyViewModel::propertiesForView() const
{
    QVariantList list;
    const int count = m_propertyListModel->rowCount();
    for (int i = 0; i < count; ++i) {
        const QModelIndex idx = m_propertyListModel->index(i, 0);
        QVariantMap row;
        row["id"] = m_propertyListModel->data(idx, PropertyListModel::IdRole);
        row["title"] = m_propertyListModel->data(idx, PropertyListModel::TitleRole);
        row["district"] = m_propertyListModel->data(idx, PropertyListModel::DistrictRole);
        row["village"] = m_propertyListModel->data(idx, PropertyListModel::VillageRole);
        row["price"] = m_propertyListModel->data(idx, PropertyListModel::PriceRole);
        row["verificationStatus"] = m_propertyListModel->data(idx, PropertyListModel::VerificationStatusRole);
        row["propertyType"] = m_propertyListModel->data(idx, PropertyListModel::PropertyTypeRole);
        row["agentId"] = m_propertyListModel->data(idx, PropertyListModel::AgentIdRole);
        list.append(row);
    }
    return list;
}

void PropertyViewModel::getPropertyById(const QString &houseId)
{
    setLoading(true);
    m_propertyController->getPropertyById(houseId);
}

int PropertyViewModel::indexOfProperty(const QString &houseId) const
{
    const int count = m_propertyListModel->rowCount();
    for (int i = 0; i < count; ++i) {
        const QModelIndex idx = m_propertyListModel->index(i, 0);
        const QString id = m_propertyListModel->data(idx, PropertyListModel::IdRole).toString();
        if (id == houseId)
            return i;
    }
    return -1;
}

void PropertyViewModel::updateProperty(int index, const QString &houseId, const QString &title, const QString &description, double price, const QString &district, const QString &village, const QStringList &amenities, const QString &landlord, const QString &landlordPhone, const QString &verificationStatus, bool isActive)
{
    m_index = index;
    setLoading(true);
    m_propertyController->updateProperty(houseId, title, description, price, district, village, amenities, landlord, landlordPhone, verificationStatus, isActive);
}

void PropertyViewModel::createProperty(const QString &title, const QString &description, double price, const QString &propertyType, const QString &district, const QString &village, const QStringList &amenities, const QString &landlord, const QString &landlordPhone, const QString &verificationStatus, bool isActive, const QJsonArray &rooms)
{
    setLoading(true);
    m_propertyController->createProperty(title, description, price, propertyType, district, village, amenities, landlord, landlordPhone, verificationStatus, isActive, rooms);
}

void PropertyViewModel::deleteProperty(const QString &houseId)
{
    setLoading(true);
    m_propertyController->deleteProperty(houseId);
}

void PropertyViewModel::attachMedia(const QString &houseId, const QStringList &mediaIds)
{
    m_propertyController->attachMedia(houseId, mediaIds);
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
    if (property)
        emit propertyUpdatedSignal(property->getId());
}

void PropertyViewModel::onCreateProperty(Property *property)
{
    setLoading(false);
    if (property) {
        m_propertyListModel->appendProperty(property);
        emit propertyCreatedSignal(property->getId(), property->getTitle());
    }
}

void PropertyViewModel::onPropertyError(const QString &error)
{
    setLoading(false);
    emit propertyError(error);
}
