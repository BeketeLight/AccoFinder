#ifndef NOTIFICATIONVIEWMODEL_H
#define NOTIFICATIONVIEWMODEL_H

#include <QObject>
#include <QList>
#include "presentation/models/notificationlistmodel.h"
#include "models/notification.h"

// NotificationViewModel exposes a QML-facing NotificationListModel.
//
// The fetch/data-layer wiring (repository -> controller) is intentionally left
// thin here: getNotifications() currently completes with an empty model so the
// UI renders its empty state. Implement the underlying fetch (GEFEND of
// repository / controller) and populate the model via setNotifications().
class NotificationViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(NotificationListModel *notificationListModel READ notificationListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit NotificationViewModel(QObject *parent = nullptr);

    NotificationListModel *notificationListModel() const { return m_listModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getNotifications();

private:
    void setLoading(bool loading);

    bool m_isLoading = false;
    NotificationListModel *m_listModel = nullptr;

signals:
    void isLoadingChanged(bool isLoading);
    void notificationsLoaded();
};

#endif // NOTIFICATIONVIEWMODEL_H
