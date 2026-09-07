#include "roomcontroller.h"

RoomController::RoomController(QObject *parent)
    : QObject{parent},
      m_repository(new RoomRepositoryImpl(this))
{
    connect(m_repository, &RoomRepositoryImpl::roomCreated,
            this, &RoomController::roomCreated);
    connect(m_repository, &RoomRepositoryImpl::roomLoaded,
            this, &RoomController::roomLoaded);
    connect(m_repository, &RoomRepositoryImpl::roomsLoaded,
            this, &RoomController::roomsLoaded);
    connect(m_repository, &RoomRepositoryImpl::roomDeleted,
            this, &RoomController::roomDeleted);
    connect(m_repository, &RoomRepositoryImpl::error,
            this, &RoomController::onError);
}

void RoomController::createRoom(const QString &propertyId, const QString &type, bool available)
{
    if (propertyId.isEmpty()) {
        emit onError("propertyId cannot be empty");
        return;
    }
    if (type.isEmpty()) {
        emit onError("type cannot be empty");
        return;
    }
    m_repository->createRoom("", propertyId, type, available);
}

void RoomController::createRoomWithPrice(const QString &propertyId,
                                         const QString &type,
                                         double price,
                                         bool available)
{
    if (propertyId.isEmpty()) {
        emit onError("propertyId cannot be empty");
        return;
    }
    if (type.isEmpty()) {
        emit onError("type cannot be empty");
        return;
    }
    m_repository->createRoomWithPrice("", propertyId, type, price, available);
}

void RoomController::updateRoom(const QString &roomId,
                                const QString &type,
                                double price,
                                bool available)
{
    if (roomId.isEmpty()) {
        emit onError("roomId cannot be empty");
        return;
    }
    m_repository->updateRoom(roomId, type, price, available);
}

void RoomController::deleteRoom(const QString &roomId)
{
    if (roomId.isEmpty()) {
        emit onError("roomId cannot be empty");
        return;
    }
    m_repository->deleteRoom(roomId);
}

void RoomController::loadRoom(const QString &roomId)
{
    if (roomId.isEmpty()) {
        emit onError("roomId cannot be empty");
        return;
    }
    m_repository->getRoomById(roomId);
}

void RoomController::loadRooms()
{
    m_repository->getRooms();
}
