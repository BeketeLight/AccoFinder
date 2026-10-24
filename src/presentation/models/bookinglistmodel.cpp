#include "bookinglistmodel.h"

static QString bookingStatusToString(BookingStatus status)
{
    switch (status) {
    case BookingStatus::PendingPayment:  return QStringLiteral("Pending payment");
    case BookingStatus::PaymentInFlight: return QStringLiteral("Payment processing");
    case BookingStatus::Confirmed:       return QStringLiteral("Confirmed");
    case BookingStatus::Expired:         return QStringLiteral("Expired");
    case BookingStatus::Cancelled:       return QStringLiteral("Cancelled");
    case BookingStatus::Failed:          return QStringLiteral("Payment failed");
    case BookingStatus::Refunded:        return QStringLiteral("Refunded");
    case BookingStatus::Pending:         return QStringLiteral("Pending");
    case BookingStatus::Paid:            return QStringLiteral("Paid");
    }
    return QStringLiteral("Pending");
}

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
}

QHash<int, QByteArray> BookingListModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    roles[IdRole] = "bookingId";
    roles[ClientIdRole] = "clientId";
    roles[RoomIdRole] = "roomId";
    roles[PropertyIdRole] = "propertyId";
    roles[BookableItemTypeRole] = "bookableItemType";
    roles[BookableItemIdRole] = "bookableItemId";
    roles[BookingDateRole] = "bookingDate";
    roles[AmountRole] = "amount";
    roles[CommissionAmountRole] = "commissionAmount";
    roles[StatusRole] = "status";
    roles[ClientNameRole]  = "clientName";
    roles[ClientPhoneRole] = "clientPhone";
    roles[ClientEmailRole] = "clientEmail";
    // Provisional hold state, so a card can show "held - 12:34 remaining"
    // without the delegate reaching back into the Booking object.
    roles[HoldExpiresAtRole] = "holdExpiresAt";
    roles[HoldSecondsRemainingRole] = "holdSecondsRemaining";
    roles[HoldActiveRole] = "holdActive";
    return roles;
}

int BookingListModel::rowCount(const QModelIndex &parent) const
{
    // FIX: Only return size for invalid parent (root node)
    if (parent.isValid())
        return 0;

    return m_bookings.count();
}

void BookingListModel::setBookings(const QList<Booking*>& bookings)
{
    beginResetModel();
    m_bookings.clear();

    for (Booking* b : bookings) {
        if (b) {
            m_bookings.append(QSharedPointer<Booking>(b));
        }
    }

    endResetModel();
    emit countChanged(m_bookings.size());
}

QVariant BookingListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_bookings.size())
        return QVariant();

    const auto& ptr = m_bookings.at(index.row());
    if (!ptr)
        return QVariant();

    Booking* booking = ptr.data();

    switch (role)
    {
    case IdRole:
        return booking->getId();
    case ClientIdRole:
        return booking->getClientId();
    case RoomIdRole:
        return booking->getRoomId();
    case PropertyIdRole:
        return booking->getPropertyId();
    case BookableItemTypeRole:
        return booking->getBookableItemType();
    case BookableItemIdRole:
        return booking->getBookableItemId();
    case BookingDateRole:
        return booking->getBookingDate().toString("dd/MM/yyyy");
    case AmountRole:
        return booking->getAmount();
    case CommissionAmountRole:
        return booking->getCommissionAmount();
    case StatusRole:
        return bookingStatusToString(booking->getStatus());
    case ClientNameRole:  return booking->getClientName();
    case ClientPhoneRole: return booking->getClientPhone(); //B added
    case ClientEmailRole: return booking->getClientEmail();
    case HoldExpiresAtRole: return booking->getHoldExpiresAt();
    case HoldSecondsRemainingRole: return booking->getHoldSecondsRemaining();
    case HoldActiveRole: return booking->getHoldActive();
    }

    return QVariant();
}

void BookingListModel::addBooking(Booking* booking)
{
    if (!booking)
        return;

    int newIndex = m_bookings.size();
    beginInsertRows(QModelIndex(), newIndex, newIndex); // FIX: Correct range [N, N]
    m_bookings.append(QSharedPointer<Booking>(booking));
    endInsertRows();

    emit countChanged(m_bookings.size());
    emit bookingAdded(booking);
}

void BookingListModel::removeBooking(int index)
{
    if (index < 0 || index >= m_bookings.size())
        return;

    beginRemoveRows(QModelIndex(), index, index); // FIX: Correct range [index, index]
    m_bookings.removeAt(index);
    endRemoveRows();

    emit countChanged(m_bookings.size());
}

void BookingListModel::clear()
{
    if (m_bookings.isEmpty())
        return;

    beginResetModel();
    m_bookings.clear();
    endResetModel();
    emit countChanged(0);
}

QVariantMap BookingListModel::at(int index) const
{
    if (index < 0 || index >= m_bookings.size())
        return QVariantMap();
    const QModelIndex idx = this->index(index, 0);
    QVariantMap row;
    row["bookingId"] = data(idx, IdRole);
    row["clientId"] = data(idx, ClientIdRole);
    row["roomId"] = data(idx, RoomIdRole);
    row["propertyId"] = data(idx, PropertyIdRole);
    row["bookableItemType"] = data(idx, BookableItemTypeRole);
    row["bookableItemId"] = data(idx, BookableItemIdRole);
    row["bookingDate"] = data(idx, BookingDateRole);
    row["amount"] = data(idx, AmountRole);
    row["commissionAmount"] = data(idx, CommissionAmountRole);
    row["status"] = data(idx, StatusRole);
    row["clientName"] = data(idx, ClientNameRole);
    row["clientPhone"] = data(idx, ClientPhoneRole);
    row["clientEmail"] = data(idx, ClientEmailRole);
    return row;
}

int BookingListModel::countByStatus(BookingStatus status) const
{
    int count = 0;
    for (const auto& b : m_bookings) {
        if (b && b->getStatus() == status)
            ++count;
    }
    return count;
}

double BookingListModel::sumAmount() const
{
    // Only realised bookings count towards booking value. Under the hold model a
    // booking can sit in PendingPayment / PaymentInFlight, or end as Expired /
    // Failed / Cancelled / Refunded without ever being paid; including those
    // inflated the figure with holds that were never actually taken.
    double total = 0.0;
    for (const auto& b : m_bookings) {
        if (!b)
            continue;
        const BookingStatus status = b->getStatus();
        if (status == BookingStatus::Confirmed || status == BookingStatus::Paid)
            total += b->getAmount();
    }
    return total;
}

double BookingListModel::sumCommission() const
{
    // Commission is only earned on confirmed (paid) bookings, mirroring the
    // server-side aggregation in the dashboard controller.
    double total = 0.0;
    for (const auto& b : m_bookings) {
        if (!b)
            continue;
        const BookingStatus status = b->getStatus();
        if (status == BookingStatus::Confirmed || status == BookingStatus::Paid)
            total += b->getCommissionAmount();
    }
    return total;
}