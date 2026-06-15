#ifndef REVIEWLISTMODEL_H
#define REVIEWLISTMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QList>
#include <QByteArray>
#include <QVector>
#include "models/review.h"

class ReviewListModel : public QAbstractListModel
{
    Q_OBJECT
    //custom rows for QML access
public:
    enum reviewRoles{
        IdRole = Qt::UserRole,
        RatingRole,
        CommentRole,
        CreatedAtRole,
    };

    explicit ReviewListModel(QObject *parent = nullptr);
    ~ReviewListModel();

    // Header:
    QVariant headerData(int section,
                        Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // === INVOCABLE METHODS FOR QML
    Q_INVOKABLE void addReview(Review* review);
    Q_INVOKABLE void removeReview(int index);
   

signals:
    void countChanged(int newcount);
    void reviewSubmitted(Review* review);

private:
    QVector<QSharedPointer<Review>> m_reviews; //storing pointers to review objetct
};

#endif // REVIEWLISTMODEL_H
