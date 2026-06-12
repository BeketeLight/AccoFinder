#ifndef NOTIFICATIONDTO_H
#define NOTIFICATIONDTO_H

#include <QJsonObject>
#include "models/notification.h"


class NotificationDto
{
public:
    NotificationDto();
    NotificationDto(QString status);

     NotificationDto(QString id,
                    QString message,
                    QString type,
                    QString status);



    QString m_id;
    QString m_message;
    QString m_type;
    QString m_status;


    static NotificationDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;
    QJsonObject toUpdateJson() const;

    Notification* toDomainModel() const;
};

#endif // NOTIFICATIONDTO_H
