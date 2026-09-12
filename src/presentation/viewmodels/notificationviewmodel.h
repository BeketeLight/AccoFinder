#ifndef NOTIFICATIONVIEWMODEL_H
#define NOTIFICATIONVIEWMODEL_H

#include <QObject>
#include <QList>
#include "presentation/models/notificationlistmodel.h"
#include "models/notification.h"
#include "services/notificationserviceimpl.h"

// NotificationViewModel exposes a QML-facing NotificationListModel.
//
// The fetch/data-layer wiring is handled here: getNotifications() asks the
// NotificationServiceImpl for this user's notifications and populates the model
// via setNotifications().
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
    // Fetch notifications targeted at a specific role (e.g. "AGENT"). Used by
    // the agent dashboard so an admin sees agent-addressed notifications only,
    // not admin-targeted ones like "house requires approval".
    Q_INVOKABLE void getNotificationsByRole(const QString& role);
    // Re-fetch notifications using the scope of the last fetch (unscoped or
    // role-scoped). Used after marking a notification as read and by the badge
    // polling timer, so the refresh preserves the active dashboard's scope.
    Q_INVOKABLE void refreshCurrent();
    Q_INVOKABLE void markAllRead();
    Q_INVOKABLE void markRead(const QString& id);

private:
    void setLoading(bool loading);

    bool m_isLoading = false;
    QString m_lastRole;
    NotificationListModel *m_listModel = nullptr;
    NotificationServiceImpl *m_service = nullptr;

signals:
    void isLoadingChanged(bool isLoading);
    void notificationsLoaded();
};

#endif // NOTIFICATIONVIEWMODEL_H
