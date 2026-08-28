#include "roomlistmodel.h"

RoomListModel::RoomListModel(QObject *parent)
    : QAbstractListModel(parent)
{}


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
    if (!index.isValid() || index.row() < 0 || index.row() >= m_rooms.size())
        return QVariant();
    QSharedPointer<Room> room = m_rooms.at(index.row());
    if (!room)
        return QVariant();

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

void RoomListModel::setRooms(QList<QSharedPointer<Room>> newRooms)
{
    beginResetModel();
    m_rooms = newRooms;
    endResetModel();
}

void RoomListModel::apppendRoom(QSharedPointer<Room> room)
{
    beginInsertRows(
        QModelIndex(),
        m_rooms.size(),
        m_rooms.size());

    m_rooms.append(room);

    endInsertRows();
}

int RoomListModel::availableCount() const
{
    int count = 0;
    for (const auto& room : m_rooms) {
        if (room && room->getAvailable())
            ++count;
    }
    return count;
}

int RoomListModel::bookedCount() const
{
    int count = 0;
    for (const auto& room : m_rooms) {
        if (room && !room->getAvailable())
            ++count;
    }
    return count;
}
