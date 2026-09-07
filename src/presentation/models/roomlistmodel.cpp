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

    case PriceRole:
        return room->getPrice();

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
        {CreatedAtRole,"createdAt"},
        {PriceRole,"price"}
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

void RoomListModel::upsertRoom(QSharedPointer<Room> room)
{
    if (!room)
        return;
    for (int i = 0; i < m_rooms.size(); ++i) {
        if (m_rooms.at(i) && m_rooms.at(i)->getId() == room->getId()) {
            m_rooms[i] = room;
            emit dataChanged(index(i), index(i));
            return;
        }
    }
    apppendRoom(room);
}

void RoomListModel::removeRoom(const QString& roomId)
{
    for (int i = 0; i < m_rooms.size(); ++i) {
        if (m_rooms.at(i) && m_rooms.at(i)->getId() == roomId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_rooms.removeAt(i);
            endRemoveRows();
            return;
        }
    }
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

QVariantList RoomListModel::roomsForProperty(const QString &propertyId) const
{
    QVariantList result;
    for (const auto& room : std::as_const(m_rooms)) {
        if (!room)
            continue;
        if (room->getPropertyId() != propertyId)
            continue;
        QVariantMap m;
        m["roomId"] = room->getId();
        m["roomType"] = room->getType();
        m["price"] = room->getPrice();
        m["available"] = room->getAvailable();
        result.append(m);
    }
    return result;
}
