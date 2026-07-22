#ifndef ROOMCONTROLLER_H
#define ROOMCONTROLLER_H

#include <QObject>
#include <QList>
#include "models/room.h"

class RoomController : public QObject
{
    Q_OBJECT
public:
    explicit RoomController(QObject *parent = nullptr);
    void reateRoom(Room* room);
    void loadRoom(Room* room);
    void loadRooms(QList<QSharedPointer<Room> > &rooms);

signals:
    void roomCreated(const QSharedPointer<Room> &room);
    void roomLoaded(const QSharedPointer<Room>& room);
    void roomsLoaded(const QList<QSharedPointer<Room>>& rooms);
    void onError(const QString& message);
};

#endif // ROOMCONTROLLER_H
