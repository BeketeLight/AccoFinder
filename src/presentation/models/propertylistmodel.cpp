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
        case TitleRole:
            return property->getTitle();
        case LocationRole:
            return property->getLocation();
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

    }

    // FIXME: Implement me!
     return QVariant();
}

QHash<int, QByteArray> PropertyListModel::roleNames() const
{
    static QHash<int,QByteArray> mapping{
        {IdRole, "id"},
        {TitleRole, "title"},
        {LocationRole, "location"},
        {AgentIdRole, "agentId"},
        {LandlordIdRole, "landlordId"},
        {CreatedAtRole, "createdAt"},
        {DescriptionRole, "description"},
        {StatusRole, "status"}
    };
    return mapping;
}

void PropertyListModel::setProperties(QList<Property*>&  newProperties)
{
    beginInsertRows(
        QModelIndex(),
        rowCount(),
        rowCount());

    m_properties = newProperties;

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