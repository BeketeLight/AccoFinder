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

public:
    explicit ReviewViewModel(QObject* parent = nullptr);

    ReviewListModel* model() const { return m_model; }
    bool loading() const { return m_loading; }

    Q_INVOKABLE void loadForProperty(const QString& propertyId);
    Q_INVOKABLE void loadForAgent(const QString& agentId);
    Q_INVOKABLE void submitReview(const QString& propertyId,
                                  const QString& agentId,
                                  int rating,
                                  const QString& comment);
    Q_INVOKABLE void editReview(const QString& id, int rating, const QString& comment);
    Q_INVOKABLE void removeReview(const QString& id);

signals:
    void loadingChanged();
    void errorOccurred(const QString& message);

private:
    void setLoading(bool v);

    ReviewController* m_controller = nullptr;   // owned internally, parent = this
    ReviewListModel*  m_model      = nullptr;   // owned internally, parent = this
    bool m_loading = false;
};

#endif // REVIEWVIEWMODEL_H