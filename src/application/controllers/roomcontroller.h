#ifndef ROOMCONTROLLER_H
#define ROOMCONTROLLER_H

#include <QObject>
#include <QSharedPointer>
#include "repositories/impl/roomrepositoryimpl.h"
#include "models/room.h"

class RoomController : public QObject
{
    Q_OBJECT
public:
    explicit RoomController(QObject *parent = nullptr);
    void createRoom(const QString& id,
                    const QString& propertyId,
                    const QString& type,
                    bool available);
    void getRooms();
    void getRoomById(const QString& id);
    void updateRoom(Room* room);
    void deleteRoom(const QString& id);
private:
    QSharedPointer<RoomRepositoryImpl> m_roomRepositoryImpl;
signals:
    void roomsLoaded(const QList<QSharedPointer<Room>>& rooms);
    void roomLoaded(const QSharedPointer<Room> &room);
    void roomCreated(const QSharedPointer<Room> &room);
    void error(const QString& message);
};

#endif // ROOMCONTROLLER_H