#ifndef ROOMLISTMODEL_H
#define ROOMLISTMODEL_H

#include <QAbstractListModel>
#include <QByteArray>
#include <QHash>
#include <QVector>
#include "models/room.h"

class RoomListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum {
        IdRole = Qt::UserRole + 1,
        PropertyIdRole,
        AgentIdRole,
        LandlordIdRole,
        TypeRole,
        AvailableRole ,
        TitleRole,
        LocationRole,
        CreatedAtRole,
    };
    explicit RoomListModel(QObject *parent = nullptr);

    // Header:
    QVariant headerData(int section,
                        Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int,QByteArray> roleNames() const override;

    void setRooms(Room* newRooms);

private:
    QVector<Room*> m_rooms;
};

#endif // ROOMLISTMODEL_H
