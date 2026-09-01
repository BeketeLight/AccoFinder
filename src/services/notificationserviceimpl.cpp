#include "notificationserviceimpl.h"
#include <QJsonArray>

NotificationServiceImpl::NotificationServiceImpl(QObject *parent)
    : INotificationRepository(parent)
{
}

void NotificationServiceImpl::createNotification(QString id,QString message,QString type, QString status)
{
    NotificationDto dto (id,message,type,status);
    APIClient::instance().post(
        "/notifications",
        dto.toJson(),
        [this](bool success,
               const QJsonObject& response)
        {
            if(success){
                NotificationDto notificationDto = NotificationDto::fromJson(response["data"].toObject());
                Notification* notification = notificationDto.toDomainModel();
                emit notificationCreated(notification);

            }
        }
        );

}

void NotificationServiceImpl::getNotification(const QString& id)
{
    APIClient::instance().get(
        "/notifications/" + id,
        [this](bool success,
               const QJsonObject& response)
        {
            if(success){
                NotificationDto dto = NotificationDto::fromJson(response["data"].toObject());
                Notification* notification = dto.toDomainModel();
                emit notificationRetrieved(notification);
            }
        }
        );

}

void NotificationServiceImpl::getUserNotifications()
{
    APIClient::instance().get(
        "/notifications",
        [this](bool success,
               const QJsonObject& response)
        {
            QList<Notification*> notifications;
            if (success && response.contains("data")) {
                const QJsonArray data = response["data"].toArray();
                for (const QJsonValue& value : data) {
                    NotificationDto dto = NotificationDto::fromJson(value.toObject());
                    notifications.append(dto.toDomainModel());
                }
            }
            emit notificationsRetrieved(notifications);
        }, false
    );
}

void NotificationServiceImpl::markReadNotification(const QString &id, QString& status)
{
    NotificationDto dto(status);
    APIClient::instance().patch(
        "/notifications/" + id + "/read",
        dto.toUpdateJson(),
        [this](bool success,
                    const QJsonObject& response)
        {
            if(success)
            {
                emit notificationMarkedRead();
            }

        }
        );

}

void NotificationServiceImpl::markAllReadNotification()
{
    APIClient::instance().patch(
        "/notifications/read/all",
        QJsonObject(),
        [this](bool success,
               const QJsonObject& response)
        {
            Q_UNUSED(response);
            if(success)
            {
                emit allNotificationsMarkedRead();
            }

        }, false
        );

}
