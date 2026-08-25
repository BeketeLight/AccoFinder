#include "roomviewmodel.h"

RoomViewModel::RoomViewModel(QObject *parent)
    : QObject(parent),
      m_roomListModel(new RoomListModel(this)),
      m_roomController(new RoomController(this))
{
    connect(m_roomController, &RoomController::roomCreated,
            this, &RoomViewModel::onRoomCreated);
    connect(m_roomController, &RoomController::roomLoaded,
            this, &RoomViewModel::onRoomLoaded);
    connect(m_roomController, &RoomController::roomsLoaded,
            this, &RoomViewModel::onRoomsLoaded);
    connect(m_roomController, &RoomController::onError,
            this, &RoomViewModel::onError);
}

void RoomViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void RoomViewModel::loadRooms()
{
    setLoading(true);
    m_roomController->loadRooms();
}

void RoomViewModel::loadRoom(const QString &roomId)
{
    setLoading(true);
    m_roomController->loadRoom(roomId);
}

void RoomViewModel::onRoomsLoaded(const QList<QSharedPointer<Room>> &rooms)
{
    setLoading(false);
    if (m_roomListModel)
        m_roomListModel->setRooms(rooms);
}

void RoomViewModel::onRoomLoaded(const QSharedPointer<Room> &room)
{
    setLoading(false);
    if (m_roomListModel)
        m_roomListModel->apppendRoom(room);
}

void RoomViewModel::onRoomCreated(const QSharedPointer<Room> &room)
{
    setLoading(false);
    if (m_roomListModel)
        m_roomListModel->apppendRoom(room);
}

void RoomViewModel::onError(const QString &message)
{
    setLoading(false);
    emit roomError(message);
}
