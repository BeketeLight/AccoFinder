#ifndef NOTIFICATIONSERVICEIMPL_H
#define NOTIFICATIONSERVICEIMPL_H

#include "repositories/interfaces/INotification.h"
#include "models/landlord.h"

class NotificationServiceImpl : public INotificationRepository
{
public:
    NotificationServiceImpl();
    Notification* sendNotification() override;
    Notification* getNotification() override;
    Notification* markReadNotification(const QString& id) override;
    Notification* markAllReadNotification() override;
private:

};

#endif // NOTIFICATIONSERVICEIMPL_H
