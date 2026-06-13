#include "notificationdto.h"

NotificationDto::NotificationDto()
{}

NotificationDto::NotificationDto(QString status)
:m_status(status)
{

}

NotificationDto::NotificationDto(QString id, QString message, QString type, QString status)
    : m_id(id),
    m_message(message),
    m_type(type),
    m_status(status)
{

}

NotificationDto NotificationDto::fromJson(const QJsonObject &json)
{
    NotificationDto dto;

    dto.m_id =
        json["id"].toString();

    dto.m_message =
        json["message"].toString();

    dto.m_type =
        json["type"].toString();


    return dto;

}

QJsonObject NotificationDto::toJson() const
{
    QJsonObject json;

    json["id"] = m_id;
    json["message"] = m_message;
    json["type"] = m_type;

    return json;

}
QJsonObject NotificationDto::toUpdateJson() const
{
    QJsonObject json;

    json["status"] = m_status;

    return json;

}

Notification *NotificationDto::toDomainModel() const
{
    Notification* notification = new Notification();

    notification->setId(m_id);
    notification->setMessage(m_message);
    notification->setType(m_type);

    return notification;
}
