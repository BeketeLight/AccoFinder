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
    Q_INVOKABLE void markAllRead();
    Q_INVOKABLE void markRead(const QString& id);

private:
    void setLoading(bool loading);

    bool m_isLoading = false;
    NotificationListModel *m_listModel = nullptr;
    NotificationServiceImpl *m_service = nullptr;

signals:
    void isLoadingChanged(bool isLoading);
    void notificationsLoaded();
};

#endif // NOTIFICATIONVIEWMODEL_H
