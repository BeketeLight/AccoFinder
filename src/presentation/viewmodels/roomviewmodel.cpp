#include "roomviewmodel.h"

RoomViewModel::RoomViewModel(QObject *parent)
    :QObject(parent)
{
    connect(m_roomController.data(),&RoomController::roomCreated,
            this,&RoomViewModel::onRoomCreated);
    connect(m_roomController.data(),&RoomController::roomLoaded,
            this,&RoomViewModel::onRoomLoaded);
    connect(m_roomController.data(),&RoomController::roomsLoaded,
            this,&RoomViewModel::onRoomsLoaded);
}

void RoomViewModel::onRoomsLoaded(const QList<QSharedPointer<Room> > &rooms)
{
    if(m_roomListModel)
    {
        m_roomListModel->setRooms(rooms);
    }

}

void RoomViewModel::onRoomLoaded(const QSharedPointer<Room>& room)
{
    if(m_roomListModel)
    {
        m_roomListModel->apppendRoom(room);
    }

}

void RoomViewModel::onRoomCreated(const QSharedPointer<Room> &room)
{
    
}

void RoomViewModel::onError(const QString &message)
{
    
}
