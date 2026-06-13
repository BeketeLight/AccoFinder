#include "notificationserviceimpl.h"

NotificationServiceImpl::NotificationServiceImpl()
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
        "/notifications/:"+ id,
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

void NotificationServiceImpl::markReadNotification(const QString &id, QString& status)
{
    NotificationDto dto(status);
    APIClient::instance().patch(
        "/notification/: "+ id+"/read",
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

void NotificationServiceImpl::markAllReadNotification(QString& status)
{
    NotificationDto dto(status);
    APIClient::instance().patch(
        "/notification/read/all",
        dto.toUpdateJson(),
        [this](bool success,
               const QJsonObject& response)
        {
            if(success)
            {
                emit allNotificationsMarkedRead();
            }

        }
        );

}
