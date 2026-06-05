#ifndef INOTIFICATION_H
#define INOTIFICATION_H

#include <QObject>
#include "models/notification.h"

class INotificationRepository : public QObject
{
    Q_OBJECT
public:
    explicit INotificationRepository(QObject *prent = nullptr);
    virtual Notification sendNotification() = 0;
};

#endif // INOTIFICATION_H
