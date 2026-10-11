#include "reviewviewmodel.h"

ReviewViewModel::ReviewViewModel(QObject* parent)
    : QObject(parent),
    m_controller(new ReviewController(this)),
    m_model(new ReviewListModel(this))
{
    connect(m_controller, &ReviewController::reviewsFetched, this,
            [this](const QList<QSharedPointer<Review>>& list) {
                m_model->clear();
                for (const auto& r : list)
                    m_model->addReview(r);
                setLoading(false);
            });

    connect(m_controller, &ReviewController::reviewCreated, this,
            [this](QSharedPointer<Review> r) {
                m_model->addReview(r);
                setLoading(false);
            });

    connect(m_controller, &ReviewController::reviewUpdated, this,
            [this](QSharedPointer<Review> r) {
                Q_UNUSED(r);
                setLoading(false);
            });   // properly closed

    connect(m_controller, &ReviewController::reviewDeleted, this,
            [this](const QString& id) {
                Q_UNUSED(id);
                setLoading(false);
            });

    connect(m_controller, &ReviewController::error, this,
            [this](const QString& e) {
                setLoading(false);
                emit errorOccurred(e);
            });
}

void ReviewViewModel::setLoading(bool v)
{
    if (m_loading == v) return;
    m_loading = v;
    emit loadingChanged();
}

void ReviewViewModel::loadForProperty(const QString& propertyId)
{
    setLoading(true);
    m_controller->loadReviewsForProperty(propertyId);
}

void ReviewViewModel::loadForAgent(const QString& agentId)
{
    setLoading(true);
    m_controller->loadReviewsForAgent(agentId);
}

void ReviewViewModel::submitReview(const QString& propertyId,
                                   const QString& agentId,
                                   int rating,
                                   const QString& comment)
{
    setLoading(true);
    m_controller->submitReview(propertyId, agentId, rating, comment);
}

void ReviewViewModel::editReview(const QString& id, int rating, const QString& comment)
{
    m_controller->editReview(id, rating, comment);
}

void ReviewViewModel::removeReview(const QString& id)
{
    m_controller->removeReview(id);
}