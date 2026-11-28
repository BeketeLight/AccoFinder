#include "disputeslistmodel.h"

#include <QDebug>
#include <QtAlgorithms>

#include <utility>

DisputesListModel::DisputesListModel()
    : DisputesListModel(nullptr)
{
}

DisputesListModel::DisputesListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int DisputesListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_disputes.size();
}

QVariant DisputesListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_disputes.size())
        return QVariant();

    Dispute *dispute = m_disputes.at(index.row());
    if (!dispute)
        return QVariant();

    switch (role) {
    case IdRole:
        return dispute->getId();
    case BookingIdRole:
        return dispute->getBookingId();
    case IssueRole:
        return dispute->getIssue();
    case StatusRole:
        switch (dispute->getStatus()) {
        case DisputeStatus::Open:
            return QStringLiteral("open");
        case DisputeStatus::Resolved:
            return QStringLiteral("resolved");
        case DisputeStatus::Rejected:
            return QStringLiteral("rejected");
        }
        break;
    default:
        break;
    }

    return QVariant();
}

QHash<int, QByteArray> DisputesListModel::roleNames() const
{
    static const QHash<int, QByteArray> mappings {
        { IdRole, "id" },
        { BookingIdRole, "bookingId" },
        { IssueRole, "issue" },
        { StatusRole, "status" }
    };
    return mappings;
}

void DisputesListModel::setDisputes(const QList<DisputeDto> &disputes)
{
    const int previousCount = m_disputes.size();

    beginResetModel();
    qDeleteAll(m_disputes);
    m_disputes.clear();
    m_disputes.reserve(disputes.size());
    for (const DisputeDto &dto : std::as_const(disputes))
        m_disputes.append(dto.toDomainModel(this));
    endResetModel();

    // A reset already invalidates views; only announce a count change when the
    // size actually changed to avoid redundant QML reload cascades.
    if (previousCount != m_disputes.size())
        emit countChanged(m_disputes.size());
}

void DisputesListModel::addDispute(const DisputeDto &dto)
{
    if (dto.m_id.isEmpty())
        return;

    const int existingRow = rowById(dto.m_id);
    if (existingRow >= 0) {
        applyDto(m_disputes.at(existingRow), dto);
        const QModelIndex changed = index(existingRow);
        emit dataChanged(changed, changed,
                         { IdRole, BookingIdRole, IssueRole, StatusRole });
        return;
    }

    const int row = m_disputes.size();
    beginInsertRows(QModelIndex(), row, row);
    m_disputes.append(dto.toDomainModel(this));
    endInsertRows();
    emit countChanged(m_disputes.size());
}

void DisputesListModel::updateDispute(const DisputeDto &dto)
{
    const int row = rowById(dto.m_id);
    if (row >= 0)
        updateDispute(row, dto);
}

void DisputesListModel::updateDispute(int row, const DisputeDto &dto)
{
    if (row < 0 || row >= m_disputes.size() || dto.m_id.isEmpty())
        return;

    // A previous list reload may have moved the row. Match by id instead of
    // blindly overwriting whatever now occupies the cached index.
    int targetRow = row;
    if (m_disputes.at(row)->getId() != dto.m_id)
        targetRow = rowById(dto.m_id);
    if (targetRow < 0)
        return;

    applyDto(m_disputes.at(targetRow), dto);
    const QModelIndex changed = index(targetRow);
    emit dataChanged(changed, changed,
                     { IdRole, BookingIdRole, IssueRole, StatusRole });
}

QVariantMap DisputesListModel::at(int index) const
{
    if (index < 0 || index >= m_disputes.size())
        return QVariantMap();

    const QModelIndex row = this->index(index, 0);
    QVariantMap result;
    result[QStringLiteral("id")] = data(row, IdRole);
    result[QStringLiteral("bookingId")] = data(row, BookingIdRole);
    result[QStringLiteral("issue")] = data(row, IssueRole);
    result[QStringLiteral("status")] = data(row, StatusRole);
    return result;
}

int DisputesListModel::rowById(const QString &id) const
{
    if (id.isEmpty())
        return -1;

    for (int i = 0; i < m_disputes.size(); ++i) {
        if (m_disputes.at(i) && m_disputes.at(i)->getId() == id)
            return i;
    }
    return -1;
}

void DisputesListModel::applyDto(Dispute *target, const DisputeDto &dto)
{
    if (!target)
        return;

    target->setId(dto.m_id);
    target->setBookingId(dto.m_bookingId);
    target->setIssue(dto.m_issue);
    target->setStatus(dto.m_status);
}
