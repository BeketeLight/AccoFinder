#include "notificationviewmodel.h"

NotificationViewModel::NotificationViewModel(QObject *parent)
    : QObject(parent)
    , m_listModel(new NotificationListModel(this))
    , m_service(new NotificationServiceImpl(this))
{
    connect(m_service, &NotificationServiceImpl::notificationsRetrieved,
            this, [this](QList<Notification*> notifications) {
        m_listModel->setNotifications(notifications);
        setLoading(false);
        emit notificationsLoaded();
    });
}

void NotificationViewModel::setLoading(bool loading)
{
    if (m_isLoading == loading)
        return;
    m_isLoading = loading;
    emit isLoadingChanged(m_isLoading);
}

void NotificationViewModel::getNotifications()
{
    setLoading(true);
    m_service->getUserNotifications();
}

void NotificationViewModel::markAllRead()
{
    m_service->markAllReadNotification();
}

void NotificationViewModel::markRead(const QString& id)
{
    QString status = "READ";
    m_service->markReadNotification(id, status);
}
