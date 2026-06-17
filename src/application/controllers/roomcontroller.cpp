#include "roomcontroller.h"

RoomController::RoomController(QObject *parent)
    : QObject{parent}
{
    connect(m_roomRepositoryImpl.data(),&RoomRepositoryImpl::roomCreated,
            this,&RoomController::roomCreated);
    connect(m_roomRepositoryImpl.data(),&RoomRepositoryImpl::roomLoaded,
            this,&RoomController::roomLoaded);
    connect(m_roomRepositoryImpl.data(),&RoomRepositoryImpl::roomsLoaded,
            this,&RoomController::roomsLoaded);
}

void RoomController::createRoom(const QString &id,
                                const QString &propertyId,
                                const QString &type,
                                bool available)
{
    if(m_roomRepositoryImpl != nullptr)
    {
        m_roomRepositoryImpl->createRoom(id,propertyId,type,available);
    }
}

void RoomController::getRooms()
{
    if(m_roomRepositoryImpl != nullptr)
    {
        m_roomRepositoryImpl->getRooms();
    }
}

void RoomController::getRoomById(const QString &id)
{
    if(m_roomRepositoryImpl != nullptr)
    {
        m_roomRepositoryImpl->getRoomById(id);
    }
}

void RoomController::updateRoom(Room *room)
{
    
}

void RoomController::deleteRoom(const QString &id)
{
    if(m_roomRepositoryImpl != nullptr)
    {
        m_roomRepositoryImpl->deleteRoom(id);
    }
}
