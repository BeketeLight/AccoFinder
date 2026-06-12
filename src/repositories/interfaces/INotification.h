#ifndef INOTIFICATION_H
#define INOTIFICATION_H

#include <QObject>
#include <QString>
#include "models/notification.h"

class INotificationRepository : public QObject
{
    Q_OBJECT
public:
    explicit INotificationRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    virtual Notification* sendNotification() = 0;
    virtual Notification* getNotification() =0;
    virtual Notification* markReadNotification( const QString& id) =0;
    virtual Notification* markAllReadNotification() =0;

    virtual ~INotificationRepository() {}
};

#endif // INOTIFICATION_H
