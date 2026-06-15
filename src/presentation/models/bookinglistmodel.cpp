#include "bookinglistmodel.h"

BookingListModel::BookingListModel(QObject *parent)
    : QAbstractListModel(parent)
{}
BookingListModel::~BookingListModel()
{}

QVariant BookingListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    Q_UNUSED(section);
    Q_UNUSED(orientation);
    Q_UNUSED(role);
    return QVariant();
    // FIXME: Implement me!
}

QHash<int, QByteArray> BookingListModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
        roles[IdRole] = "bookingId";
        roles[ClientIdRole] ="clientId";
        roles[RoomIdRole] = "roomId";
        roles[BookingDateRole] = "bookingDate";
        roles[AmountRole] = "amount";
        roles[CommissionAmountRole] = "commissionAmount";
        return roles;
}

int BookingListModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    Q_UNUSED(parent);
    return m_bookings.count();

    // FIXME: Implement me!
}

QVariant BookingListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    Booking* booking = m_bookings.at(index.row()).data();   
    
    switch (role)
    {
    case IdRole:
        return booking->getId();
    case ClientIdRole:
        return booking->getClientId();
    case RoomIdRole:
        return booking->getRoomId();    
    case BookingDateRole:
        return booking->getBookingDate().toString("dd/MM/yyyy"); 
    case AmountRole:
        return booking->getAmount(); 
    case CommissionAmountRole:
        return booking->getCommissionAmount(); 
    
    }

    // FIXME: Implement me!
    return QVariant();
}

void BookingListModel::addBooking(Booking* booking) 
{
    if(!booking)
        return ;
    beginInsertRows(QModelIndex(), m_bookings.size(), m_bookings.count());
    m_bookings.append(QSharedPointer<Booking>(booking));
    endInsertRows();
    
    emit countChanged(m_bookings.size());
    emit bookingAdded(booking);
}

void BookingListModel::removeBooking(int index)
{
    if(index < 0 || index >= m_bookings.size())
    return ;

    beginRemoveRows(QModelIndex(), m_bookings.size(), m_bookings.size());
    m_bookings.removeAt(index);
    endRemoveRows();

    emit countChanged(m_bookings.size());
}
