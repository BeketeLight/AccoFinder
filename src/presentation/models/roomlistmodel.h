#ifndef ROOMLISTMODEL_H
#define ROOMLISTMODEL_H

#include <QAbstractListModel>
#include <QByteArray>
#include <QSharedPointer>
#include <QHash>
#include <QVector>
#include <QVariantList>
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
        PriceRole,
        HoldActiveRole,
        HoldExpiresAtRole,
        StatusLabelRole,
    };
    explicit RoomListModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int,QByteArray> roleNames() const override;

    void setRooms(QList<QSharedPointer<Room>> newRooms);
    void apppendRoom(QSharedPointer<Room> room);
    void upsertRoom(QSharedPointer<Room> room);
    void removeRoom(const QString& roomId);

    int availableCount() const;
    int bookedCount() const;

    // Rooms belonging to the given property id, shaped for QML display as
    // {roomId, roomType, price, available} maps.
    QVariantList roomsForProperty(const QString& propertyId) const;
    // Shapes a room list for QML display. Shared with the per-property fetch so
    // both paths produce identical maps for the detail pages.
    static QVariantList toVariantList(const QList<QSharedPointer<Room>>& rooms);
    QVariantMap getRoomById(const QString& roomId) const; //b----added

signals:
    void countChanged(int newCount);

private:
    QVector<QSharedPointer<Room>> m_rooms;
};

#endif // ROOMLISTMODEL_H
