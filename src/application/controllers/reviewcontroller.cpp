#include "reviewcontroller.h"

ReviewController::ReviewController(QObject* parent)
    : QObject(parent),
    m_repository(new ReviewRepositoryImpl(this))
{
    connect(m_repository, &ReviewRepositoryImpl::reviewsFetched,
            this, &ReviewController::reviewsFetched);
    connect(m_repository, &ReviewRepositoryImpl::reviewCreated,
            this, &ReviewController::reviewCreated);
    connect(m_repository, &ReviewRepositoryImpl::reviewUpdated,
            this, &ReviewController::reviewUpdated);
    connect(m_repository, &ReviewRepositoryImpl::reviewDeleted,
            this, &ReviewController::reviewDeleted);
    connect(m_repository, &ReviewRepositoryImpl::error,
            this, &ReviewController::error);
    connect(m_repository, &ReviewRepositoryImpl::canReviewChecked,
            this, [this](bool can, const QString& reason, const QString& /*existingId*/) {
                setCanReview(can, reason);
            });

    connect(m_repository, &ReviewRepositoryImpl::summaryLoaded,
            this, [this](double average, int count) {
                setSummary(average, count);
            });
}

void ReviewController::loadReviewsForProperty(const QString& propertyId)
{
    if (propertyId.isEmpty()) {
        emit error("propertyId cannot be empty");
        return;
    }
    m_repository->fetchByProperty(propertyId);
}

void ReviewController::loadReviewsForAgent(const QString& agentId)
{
    if (agentId.isEmpty()) {
        emit error("agentId cannot be empty");
        return;
    }
    m_repository->fetchByAgent(agentId);
}

void ReviewController::submitReview(const QString& propertyId,
                                    const QString& agentId,
                                    int rating,
                                    const QString& comment)
{
    if (propertyId.isEmpty()) {
        emit error("propertyId cannot be empty");
        return;
    }
    if (agentId.isEmpty()) {
        emit error("agentId cannot be empty");
        return;
    }
    if (rating < 1 || rating > 5) {
        emit error("rating must be between 1 and 5");
        return;
    }
    if (comment.isEmpty()) {
        emit error("comment cannot be empty");
        return;
    }
    m_repository->createReview(propertyId, agentId, rating, comment);
}

void ReviewController::editReview(const QString& id, int rating, const QString& comment)
{
    if (id.isEmpty()) {
        emit error("review id cannot be empty");
        return;
    }
    m_repository->updateReview(id, rating, comment);
}

void ReviewController::removeReview(const QString& id)
{
    if (id.isEmpty()) {
        emit error("review id cannot be empty");
        return;
    }
    m_repository->deleteReview(id);
}

void ReviewController::checkCanReview(const QString& propertyId)
{
    if (propertyId.isEmpty()) {
        emit error("propertyId cannot be empty");
        return;
    }
    m_repository->checkCanReview(propertyId);
}

void ReviewController::loadSummary(const QString& propertyId)
{
    if (propertyId.isEmpty()) {
        emit error("propertyId cannot be empty");
        return;
    }
    m_repository->getSummary(propertyId);
}

void ReviewController::setCanReview(bool can, const QString& reason)
{
    if (m_canReview == can && m_canReviewReason == reason)
        return;
    m_canReview       = can;
    m_canReviewReason = reason;
    emit canReviewChanged();
}

void ReviewController::setSummary(double average, int count)
{
    if (qFuzzyCompare(m_averageRating, average) && m_reviewCount == count)
        return;
    m_averageRating = average;
    m_reviewCount   = count;
    emit summaryChanged();
}