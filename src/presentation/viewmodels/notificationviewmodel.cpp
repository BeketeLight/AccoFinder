#include "notificationviewmodel.h"

NotificationViewModel::NotificationViewModel(QObject *parent)
    : QObject(parent)
    , m_listModel(new NotificationListModel(this))
{}

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

    // Data-layer wiring TODO (yours): fetch notifications from the backend and
    // populate the model via m_listModel->setNotifications(...). Until then this
    // completes immediately with an empty model so the UI shows its empty state.
    setLoading(false);
    emit notificationsLoaded();
}
