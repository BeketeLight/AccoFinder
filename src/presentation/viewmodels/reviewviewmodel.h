#ifndef REVIEWVIEWMODEL_H
#define REVIEWVIEWMODEL_H

#include <QObject>
#include <QSharedPointer>
#include "application/controllers/reviewcontroller.h"
#include "presentation/models/reviewlistmodel.h"

class ReviewViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ReviewListModel* model READ model CONSTANT)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

    Q_PROPERTY(bool    canReview        READ canReview        NOTIFY canReviewChanged)
    Q_PROPERTY(QString canReviewReason  READ canReviewReason  NOTIFY canReviewChanged)
    Q_PROPERTY(double  averageRating    READ averageRating    NOTIFY summaryChanged)
    Q_PROPERTY(int     reviewCount      READ reviewCount      NOTIFY summaryChanged)

public:
    explicit ReviewViewModel(QObject* parent = nullptr);

    ReviewListModel* model() const { return m_model; }
    bool loading() const           { return m_loading; }

    // --- Q_PROPERTY getters (must match READ in Q_PROPERTY) ---
    bool    canReview() const       { return m_canReview; }
    QString canReviewReason() const { return m_canReviewReason; }
    double  averageRating() const   { return m_averageRating; }
    int     reviewCount() const     { return m_reviewCount; }

    Q_INVOKABLE void loadForProperty(const QString& propertyId);
    Q_INVOKABLE void loadForAgent(const QString& agentId);
    Q_INVOKABLE void submitReview(const QString& propertyId,
                                  const QString& agentId,
                                  int rating,
                                  const QString& comment);
    Q_INVOKABLE void editReview(const QString& id, int rating, const QString& comment);
    Q_INVOKABLE void removeReview(const QString& id);

    // --- NEW: expose the two new controller commands ---
    Q_INVOKABLE void checkCanReview(const QString& propertyId);
    Q_INVOKABLE void loadSummary(const QString& propertyId);

signals:
    void loadingChanged();
    void errorOccurred(const QString& message);

    // --- NOTIFY signals for the new properties ---
    void canReviewChanged();
    void summaryChanged();

private:
    void setLoading(bool v);

    ReviewController* m_controller = nullptr;
    ReviewListModel*  m_model      = nullptr;
    bool m_loading = false;

    // backing fields for the new properties
    bool    m_canReview       = false;
    QString m_canReviewReason;
    double  m_averageRating   = 0.0;
    int     m_reviewCount     = 0;
};

#endif // REVIEWVIEWMODEL_H