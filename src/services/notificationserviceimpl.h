#ifndef NOTIFICATIONSERVICEIMPL_H
#define NOTIFICATIONSERVICEIMPL_H

#include "repositories/interfaces/INotification.h"
#include "models/landlord.h"
#include "application/dto/notificationdto.h"
#include "services/apiclient.h"
#include "models/notification.h"

class NotificationServiceImpl : public INotificationRepository
{
    Q_OBJECT
public:
    NotificationServiceImpl();
    void createNotification(QString id,QString message,QString type, QString status) override;
    void getNotification(const QString& id) override;
    void markReadNotification(const QString& id, QString& status) override;
    void markAllReadNotification(QString& status) override;
private:
signals:
    void notificationCreated(Notification* notification);
    void notificationRetrieved(Notification* notification);
    void notificationMarkedRead();
    void allNotificationsMarkedRead();

};

#endif // NOTIFICATIONSERVICEIMPL_H
