#include "reviewlistmodel.h"

ReviewListModel::ReviewListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

ReviewListModel::~ReviewListModel()
{}

int ReviewListModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;
    return m_reviews.count();
}
QVariant ReviewListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    // FIXME: Implement me!
    Q_UNUSED(section);
    Q_UNUSED(orientation);
    Q_UNUSED(role);
    return QVariant();
}

QHash<int, QByteArray> ReviewListModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    roles[IdRole]         = "reviewId";
    roles[ClientIdRole]   = "clientId";
    roles[PropertyIdRole] = "propertyId";
    roles[AgentIdRole]    = "agentId";
    roles[RatingRole]     = "rating";
    roles[CommentRole]    = "comment";
    roles[CreatedAtRole]  = "createdAt";
    return roles;
}

QVariant ReviewListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_reviews.size())
        return QVariant();

    const auto& ptr = m_reviews.at(index.row());
    if (!ptr)
        return QVariant();

    Review* review = ptr.data();

    switch (role) {
    case IdRole:         return review->getId();
    case ClientIdRole:   return review->getClientId();
    case PropertyIdRole: return review->getPropertyId();
    case AgentIdRole:    return review->getAgentId();
    case RatingRole:     return review->getRating();
    case CommentRole:    return review->getComment();
    case CreatedAtRole:  return review->getCreatedAt().toString("dd/MM/yyyy");
    }
    return QVariant();
}

void ReviewListModel::addReview(QSharedPointer<Review> review)
{
    if (!review) return;

    beginInsertRows(QModelIndex(), m_reviews.size(), m_reviews.size());
    m_reviews.append(review);
    endInsertRows();

    emit countChanged(m_reviews.size());
}

void ReviewListModel::clear()
{
    beginResetModel();
    m_reviews.clear();
    endResetModel();
    emit countChanged(0);
}
void ReviewListModel::removeReview(int index)
{
    if(index < 0 || index >= m_reviews.size()){
        return;
    }
    beginRemoveRows(QModelIndex(), index, index);
    m_reviews.removeAt(index);
    endRemoveRows();

    emit countChanged(m_reviews.count());
}
