#include "propertylistmodel.h"

PropertyListModel::PropertyListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

// QVariant PropertyListModel::headerData(int section, Qt::Orientation orientation, int role) const
// {
//     // FIXME: Implement me!
// }

int PropertyListModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid())
        return 0;

    return m_properties.size();

    // FIXME: Implement me!
}

QVariant PropertyListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();
    Property* property = m_properties.at(index.row());

    switch(role)
    {
        case IdRole:
            return property->getId();
        case FirstNameRole:
            return property->firstName();
        case SecondNameRole:
            return property->secondName();
        case TitleRole:
            return property->getTitle();
        case LocationRole:
            return property->getLocation();
        case PriceRole:
            return property->getPrice();
        case AgentIdRole:
            return property->getAgentId();
        case LandlordIdRole:
            return property->getLandlordId();
        case CreatedAtRole:
            return property->getCreatedAt();
        case DescriptionRole:
            return property->getDescription();
        case StatusRole:
        {
            QString status = property->getVerificationStatus();
            if (!status.isEmpty())
                return status;
            switch(property->getStatus())
            {
            case PropertyStatus::NotVerified:
                return "Not Verified";

            case PropertyStatus::Verified:
                return "Verified";

            case PropertyStatus::Booked:
                return "Booked";
            }

            return "Unknown";
        }
        case DistrictRole:
            return property->getDistrict();
        case VillageRole:
            return property->getVillage();
        case AmenitiesRole:
            return property->getAmenities();
        case LandlordPhoneRole:
            return property->getLandlordPhone();
        case VerificationStatusRole:
            return property->getVerificationStatus();
        case IsActiveRole:
            return property->isActive();
        case PropertyTypeRole:
            return property->getPropertyType();

    }

    // FIXME: Implement me!
     return QVariant();
}

QHash<int, QByteArray> PropertyListModel::roleNames() const
{
    static QHash<int,QByteArray> mapping{
        {IdRole, "id"},
        {FirstNameRole, "firstName"},
        {SecondNameRole, "secondName"},
        {TitleRole, "title"},
        {LocationRole, "location"},
        {PriceRole, "price"},
        {AgentIdRole, "agentId"},
        {LandlordIdRole, "landlordId"},
        {CreatedAtRole, "createdAt"},
        {DescriptionRole, "description"},
        {StatusRole, "status"},
        {DistrictRole, "district"},
        {VillageRole, "village"},
        {AmenitiesRole, "amenities"},
        {LandlordPhoneRole, "landlordPhone"},
        {VerificationStatusRole, "verificationStatus"},
        {IsActiveRole, "isActive"},
        {PropertyTypeRole, "propertyType"}
    };
    return mapping;
}

void PropertyListModel::setProperties(QList<Property*>&  newProperties)
{
    beginResetModel();
    qDeleteAll(m_properties);
    m_properties = newProperties;
    endResetModel();
}

void PropertyListModel::appendProperty(Property* property)
{
    beginInsertRows(QModelIndex(), m_properties.size(), m_properties.size());
    m_properties.append(property);
    endInsertRows();
}

void PropertyListModel::updateProperty(int index, Property* property)
{
    if (index < 0 || index >= m_properties.size())
        return;

    beginResetModel();
    m_properties[index] = property;
    endResetModel();
}

void PropertyListModel::getPropertyById(Property* property)
{
    clear();
    updateProperty(0,property);

}
void PropertyListModel::clear()
{
    beginResetModel();

    qDeleteAll(m_properties);
    m_properties.clear();

    endResetModel();
}