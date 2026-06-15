#include "disputeslistmodel.h"

DisputesListModel::DisputesListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int DisputesListModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid())
        return 0;

    return m_disputes.size();

    // FIXME: Implement me!
}

QVariant DisputesListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();
    Dispute* dispute = m_disputes.at(index.row());

    switch (role)
    {
        case IdRole:
            return dispute->getId();
        case BookingIdRole:
            return dispute->getBookingId();
        case IssueRole:
            return dispute->getIssue();
        case StatusRole:
        {
            switch(dispute->getStatus())
            {
            case DisputeStatus::Open:
                return "open";

            case DisputeStatus::Resolved:
                return "resolved";
            }
        }
    }

    // FIXME: Implement me!
    return QVariant();
}

QHash<int, QByteArray> DisputesListModel::roleNames() const
{

    static QHash<int,QByteArray> mappings
    {
        {IdRole,"id"},
        {BookingIdRole,"bookingId"},
        {IssueRole,"issue"},
        {StatusRole,"staus"}
    };

    return mappings;

}

void DisputesListModel::addDisputes(QList<Dispute *> &disputes)
{
    beginInsertRows(
        QModelIndex(),
        rowCount(),
        rowCount());

    m_disputes = disputes;

    endInsertRows();
}
