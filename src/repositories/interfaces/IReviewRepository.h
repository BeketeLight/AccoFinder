#ifndef IREVIEWREPOSITORY_H
#define IREVIEWREPOSITORY_H

#include <QObject>
#include <QVector>
#include "models/review.h"

class IReviewRepository : public QObject
{
    Q_OBJECT
public:
    explicit IReviewRepository(QObject* parent = nullptr) : QObject(parent) {}
    virtual ~IReviewRepository() = default;

    virtual void fetchByProperty(const QString& propertyId) = 0;
    virtual void fetchByAgent(const QString& agentId) = 0;
    virtual void createReview(const QString& propertyId,
                              const QString& agentId,
                              int rating,
                              const QString& comment) = 0;
    virtual void updateReview(const QString& id, int rating, const QString& comment) = 0;
    virtual void deleteReview(const QString& id) = 0;

signals:
    void reviewsFetched(const QList<QSharedPointer<Review>>& reviews);
    void reviewCreated(QSharedPointer<Review> review);
    void reviewUpdated(QSharedPointer<Review> review);
    void reviewDeleted(const QString& id);
    void error(const QString& message);

};

#endif // IREVIEWREPOSITORY_H
