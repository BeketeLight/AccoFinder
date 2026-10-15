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
    Q_PROPERTY(bool canReview READ canReview NOTIFY canReviewChanged)
    Q_PROPERTY(QString canReviewReason READ canReviewReason NOTIFY canReviewChanged)
    Q_PROPERTY(double averageRating READ averageRating NOTIFY summaryChanged)
    Q_PROPERTY(int    reviewCount   READ reviewCount   NOTIFY summaryChanged)
public:
    explicit ReviewController(QObject* parent = nullptr);

    // --- Q_PROPERTY getters ---
    bool    canReview() const       { return m_canReview; }
    QString canReviewReason() const { return m_canReviewReason; }
    double  averageRating() const   { return m_averageRating; }
    int     reviewCount() const     { return m_reviewCount; }
    Q_INVOKABLE void checkCanReview(const QString& propertyId);
    Q_INVOKABLE void loadSummary(const QString& propertyId);

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
    void canReviewChanged();
    void summaryChanged();

private:
    void setCanReview(bool can, const QString& reason);
    void setSummary(double average, int count);
    ReviewRepositoryImpl* m_repository = nullptr;   // owned internally, parent = this

    bool    m_canReview       = false;
    QString m_canReviewReason;
    double  m_averageRating   = 0.0;
    int     m_reviewCount     = 0;
};

#endif // REVIEWCONTROLLER_H