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
    virtual void createNotification(QString id,QString message,QString type, QString status) = 0;
    virtual void getNotification(const QString& id) =0;
    virtual void markReadNotification( const QString& id,QString& status) =0;
    virtual void markAllReadNotification(QString& status) =0;

    virtual ~INotificationRepository() {}
};

#endif // INOTIFICATION_H
