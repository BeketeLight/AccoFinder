#ifndef ROOMCONTROLLER_H
#define ROOMCONTROLLER_H

#include <QObject>
#include <QList>
#include <QSharedPointer>
#include "models/room.h"
#include "repositories/impl/roomrepositoryimpl.h"

class RoomController : public QObject
{
    Q_OBJECT
public:
    explicit RoomController(QObject *parent = nullptr);

    Q_INVOKABLE void createRoom(const QString& propertyId,
                                const QString& type,
                                bool available);
    Q_INVOKABLE void loadRoom(const QString& roomId);
    Q_INVOKABLE void loadRooms();

signals:
    void roomCreated(const QSharedPointer<Room>& room);
    void roomLoaded(const QSharedPointer<Room>& room);
    void roomsLoaded(const QList<QSharedPointer<Room>>& rooms);
    void onError(const QString& message);

private:
    RoomRepositoryImpl* m_repository = nullptr;
};

#endif // ROOMCONTROLLER_H
