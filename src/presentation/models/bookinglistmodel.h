#ifndef BOOKINGLISTMODEL_H
#define BOOKINGLISTMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QVector>
#include <QByteArray>
#include <QList>
#include "models/booking.h"

class BookingListModel : public QAbstractListModel
{
    Q_OBJECT
public:
   
    enum bookingRoles{
        IdRole = Qt::UserRole,
        ClientIdRole,
        RoomIdRole,
        BookingDateRole,
        AmountRole,
        CommissionAmountRole,

    };
     explicit BookingListModel(QObject *parent = nullptr);
    ~BookingListModel();

    // Header:
    QVariant headerData(int section,
                        Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // ====== INVOKABLE METHODS FOR QML
    Q_INVOKABLE void addBooking(Booking* booking);
    Q_INVOKABLE void removeBooking(int index);
    // Q_INVOKABLE void clear();

 signals:
    void countChanged(int newCount);
    void bookingAdded(Booking* booking);

private:
    QVector<QSharedPointer<Booking>> m_bookings;
};

#endif // BOOKINGLISTMODEL_H
