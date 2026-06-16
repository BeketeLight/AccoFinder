#ifndef ROOMREPOSITORYIMPL_H
#define ROOMREPOSITORYIMPL_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include "models/room.h"
#include "services/apiclient.h"
#include <QSharedPointer>
#include "repositories/interfaces/IRoomRepository.h"
#include "application/dto/roomdto.h"

class RoomRepositoryImpl :public QObject, public IRoomRepository
{
    Q_OBJECT
public:
    RoomRepositoryImpl(QObject* parent = nullptr);
    void createRoom(const QString& id,
                    const QString& propertyId,
                    const QString& type,
                    bool available) override;
    void getRooms() override;
    void getRoomById(const QString& id) override;
    void updateRoom(Room* room) override;
    void deleteRoom(const QString& id) override;
private:
    QList<QSharedPointer<Room>> m_rooms;
signals:
    void roomsLoaded(const QList<QSharedPointer<Room>>& rooms);
    void roomLoaded(QSharedPointer<Room>);
    void roomCreated(QSharedPointer<Room>);
    void error(const QString& message);
};

#endif // ROOMREPOSITORYIMPL_H
