#ifndef NOTIFICATIONSERVICEIMPL_H
#define NOTIFICATIONSERVICEIMPL_H

#include "repositories/interfaces/INotification.h"
#include "models/landlord.h"

class NotificationServiceImpl : public INotificationRepository
{
public:
    NotificationServiceImpl();
    Notification* sendNotification() override;
private:
    Notification* notification = new Notification;
};

#endif // NOTIFICATIONSERVICEIMPL_H
