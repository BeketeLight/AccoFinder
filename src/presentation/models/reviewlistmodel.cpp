#include "reviewlistmodel.h"

ReviewListModel::ReviewListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

ReviewListModel::~ReviewListModel()
{}

int ReviewListModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
  Q_UNUSED(parent);
  return m_reviews.count();

    // FIXME: Implement me!
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
    roles[IdRole] = "reviewId";
    roles[RatingRole] = "rating";
    roles[CommentRole] = "comment";
    roles[CreatedAtRole] = "comment";
    return roles;
}

QVariant ReviewListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_reviews.size()){
        return QVariant();
    }
    
    Review* review = m_reviews.at(index.row()).data();
        // return QVariant();
    
    switch(role)
    {
    case IdRole:
        return review->getId();
    case RatingRole:
        return review->getRating();
    case CommentRole:
        return review->getComment();
    case CreatedAtRole:
        return review->getCreatedAt().toString("dd/MM/yyyy");        

    } 
    // FIXME: Implement me!
    return QVariant();
}

void ReviewListModel::addReview(Review* review)
{
    if(!review)
        return;
    
    beginInsertRows(QModelIndex(), m_reviews.size(), m_reviews.count());
    m_reviews.append(QSharedPointer<Review>(review));
    endInsertRows();

    emit countChanged(m_reviews.size());
    emit reviewSubmitted(review);
    
    qDebug() << "Review added";// for checking execution
    
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
