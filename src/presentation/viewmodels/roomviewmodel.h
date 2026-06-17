#ifndef ROOMVIEWMODEL_H
#define ROOMVIEWMODEL_H

#include <QObject>
#include "presentation/models/roomlistmodel.h"
#include "application/controllers/roomcontroller.h"

class RoomViewModel : public QObject
{
    Q_OBJECT
public:
    explicit RoomViewModel(QObject* parent = nullptr);
private:
    QSharedPointer<RoomListModel> m_roomListModel;
    QSharedPointer<RoomController> m_roomController;
private slots:
    void onRoomsLoaded(const QList<QSharedPointer<Room>>& rooms);
    void onRoomLoaded(const QSharedPointer<Room>& room);
    void onRoomCreated(const QSharedPointer<Room> &room);
    void onError(const QString& message);

};

#endif // ROOMVIEWMODEL_H
