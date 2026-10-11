#ifndef ROOMVIEWMODEL_H
#define ROOMVIEWMODEL_H

#include <QObject>
#include <QVariantList>
#include "presentation/models/roomlistmodel.h"
#include "application/controllers/roomcontroller.h"

class RoomViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(RoomListModel* roomListModel READ roomListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit RoomViewModel(QObject* parent = nullptr);

    RoomListModel* roomListModel() const { return m_roomListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void loadRooms();
    Q_INVOKABLE void loadRoom(const QString& roomId);
    // Loads only the given property's rooms and reports them via
    // roomsForPropertyLoaded (does not touch the shared roomListModel). Detail
    // pages use this so their room list stays correct regardless of the global
    // /rooms/?limit=100 page.
    Q_INVOKABLE void loadRoomsForProperty(const QString& propertyId);
    Q_INVOKABLE void createRoom(const QString& propertyId, const QString& type, bool available);
    Q_INVOKABLE void createRoomWithPrice(const QString& propertyId, const QString& type, double price, bool available);
    Q_INVOKABLE void updateRoom(const QString& roomId, const QString& type, double price, bool available);
    Q_INVOKABLE void deleteRoom(const QString& roomId);

    Q_INVOKABLE int availableRoomsCount() const;
    Q_INVOKABLE int bookedRoomsCount() const;

    // Returns the rooms that belong to the given property id as a list of
    // {roomId, roomType, price, available, holdActive, holdExpiresAt,
    // statusLabel} maps, read from the shared roomListModel cache.
    Q_INVOKABLE QVariantList roomsForProperty(const QString& propertyId) const;
    Q_INVOKABLE QVariantMap getRoomById(const QString& roomId) const; //b---added

private:
    bool m_isLoading = false;
    RoomListModel* m_roomListModel = nullptr;
    RoomController* m_roomController = nullptr;

    void setLoading(bool loading);

private slots:
    void onRoomsLoaded(const QList<QSharedPointer<Room>>& rooms);
    void onRoomLoaded(const QSharedPointer<Room>& room);
    void onRoomCreated(const QSharedPointer<Room>& room);
    void onRoomDeleted(const QString& roomId);
    void onError(const QString& message);
    void onRoomsForPropertyLoaded(const QString& propertyId,
                                  const QList<QSharedPointer<Room>>& rooms);

signals:
    void isLoadingChanged(bool isLoading);
    void roomError(const QString& error);
    void roomDeletedSignal(const QString& roomId);
    // Emitted in response to loadRoomsForProperty, carrying the same room-map
    // shape as RoomListModel::roomsForProperty.
    void roomsForPropertyLoaded(const QString& propertyId, const QVariantList& rooms);
};

#endif // ROOMVIEWMODEL_H
