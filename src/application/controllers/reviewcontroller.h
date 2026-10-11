#ifndef REVIEWCONTROLLER_H
#define REVIEWCONTROLLER_H

#include <QObject>
#include <QList>
#include <QSharedPointer>
#include "models/review.h"
#include "repositories/impl/reviewrepositoryimpl.h"

class ReviewController : public QObject
{
    Q_OBJECT
public:
    explicit ReviewController(QObject* parent = nullptr);

    // Commands (called by ViewModel)
    void loadReviewsForProperty(const QString& propertyId);
    void loadReviewsForAgent(const QString& agentId);
    void submitReview(const QString& propertyId,
                      const QString& agentId,
                      int rating,
                      const QString& comment);
    void editReview(const QString& id, int rating, const QString& comment);
    void removeReview(const QString& id);

signals:
    // Events (observed by ViewModel)
    void reviewsFetched(const QList<QSharedPointer<Review>>& reviews);
    void reviewCreated(QSharedPointer<Review> review);
    void reviewUpdated(QSharedPointer<Review> review);
    void reviewDeleted(const QString& id);
    void error(const QString& message);

private:
    ReviewRepositoryImpl* m_repository = nullptr;   // owned internally, parent = this
};

#endif // REVIEWCONTROLLER_H