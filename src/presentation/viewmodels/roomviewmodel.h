#ifndef ROOMVIEWMODEL_H
#define ROOMVIEWMODEL_H

#include <QObject>
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
    Q_INVOKABLE void createRoom(const QString& propertyId, const QString& type, bool available);

private:
    bool m_isLoading = false;
    RoomListModel* m_roomListModel = nullptr;
    RoomController* m_roomController = nullptr;

    void setLoading(bool loading);

private slots:
    void onRoomsLoaded(const QList<QSharedPointer<Room>>& rooms);
    void onRoomLoaded(const QSharedPointer<Room>& room);
    void onRoomCreated(const QSharedPointer<Room>& room);
    void onError(const QString& message);

signals:
    void isLoadingChanged(bool isLoading);
    void roomError(const QString& error);
};

#endif // ROOMVIEWMODEL_H
