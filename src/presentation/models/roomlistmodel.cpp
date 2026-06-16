#include "roomlistmodel.h"

RoomListModel::RoomListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

QVariant RoomListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    // FIXME: Implement me!
}

int RoomListModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid())
        return 0;

    return m_rooms.size();

    // FIXME: Implement me!
}

QVariant RoomListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();
    return QVariant();
    Room* room = m_rooms.at(index.row());

    switch(role)
    {
    case IdRole:
        return room->getId();
    case PropertyIdRole:
        return room->getPropertyId();
    case TypeRole:
        return room->getType();
    case AvailableRole:
        return room->getAvailable();

    }

    // FIXME: Implement me!
    return QVariant();
}

QHash<int, QByteArray> RoomListModel::roleNames() const
{
    static QHash<int,QByteArray> mapping {
        {IdRole,"id"},
        {PropertyIdRole,"propertyId"},
        {AgentIdRole,"agentId"},
        {LandlordIdRole,"landlordId"},
        {TypeRole,"type"},
        {AvailableRole,"available"},
        {TitleRole,"title"},
        {LocationRole,"location"},
        {CreatedAtRole,"createdAt"}
    };

    return mapping;
}

void RoomListModel::setRooms(Room* newRooms)
{
    beginInsertRows(
        QModelIndex(),
        rowCount(),
        rowCount());

    m_rooms.append(newRooms);

    endInsertRows();
}
