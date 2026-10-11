#ifndef REVIEWLISTMODEL_H
#define REVIEWLISTMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QList>
#include <QByteArray>
#include <QVector>
#include <QSharedPointer>
#include "models/review.h"

class ReviewListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum reviewRoles {
        IdRole = Qt::UserRole,
        ClientIdRole,
        PropertyIdRole,
        AgentIdRole,
        RatingRole,
        CommentRole,
        CreatedAtRole,
    };

    explicit ReviewListModel(QObject* parent = nullptr);
    ~ReviewListModel();

    QVariant headerData(int section,
                        Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int count() const { return m_reviews.size(); }

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addReview(QSharedPointer<Review> review);
    Q_INVOKABLE void removeReview(int index);
    Q_INVOKABLE void clear();

signals:
    void countChanged(int newcount);

private:
    QVector<QSharedPointer<Review>> m_reviews;
};

#endif // REVIEWLISTMODEL_H