#ifndef NOTIFICATIONSERVICEIMPL_H
#define NOTIFICATIONSERVICEIMPL_H

#include <QList>
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
    void getUserNotifications() override;
    void markReadNotification(const QString& id, QString& status) override;
    void markAllReadNotification() override;
private:
signals:
    void notificationCreated(Notification* notification);
    void notificationRetrieved(Notification* notification);
    void notificationsRetrieved(QList<Notification*> notifications);
    void notificationMarkedRead();
    void allNotificationsMarkedRead();

};

#endif // NOTIFICATIONSERVICEIMPL_H
