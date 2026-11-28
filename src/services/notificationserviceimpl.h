#ifndef NOTIFICATIONSERVICEIMPL_H
#define NOTIFICATIONSERVICEIMPL_H

#include <QList>
#include <QSet>
#include "repositories/interfaces/INotification.h"
#include "models/landlord.h"
#include "application/dto/notificationdto.h"
#include "services/apiclient.h"
#include "models/notification.h"

class NotificationServiceImpl : public INotificationRepository
{
    Q_OBJECT
public:
    explicit NotificationServiceImpl(QObject *parent = nullptr);
    void createNotification(QString id,QString message,QString type, QString status) override;
    void getNotification(const QString& id) override;
    void getUserNotifications(const QString& role = QString()) override;
    void markReadNotification(const QString& id, QString& status) override;
    void markAllReadNotification() override;
private:
    // Startup, the badge timer, push callbacks and landing pages can all ask
    // for the same notification feed at once. One GET per URL is enough.
    QSet<QString> m_inFlightUrls;
signals:
    void notificationCreated(Notification* notification);
    void notificationRetrieved(Notification* notification);
    void notificationsRetrieved(QList<Notification*> notifications);
    void notificationMarkedRead();
    void allNotificationsMarkedRead();

};

#endif // NOTIFICATIONSERVICEIMPL_H
