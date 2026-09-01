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
        json["_id"].toString();
    if (dto.m_id.isEmpty())
        dto.m_id = json["id"].toString();

    dto.m_message =
        json["message"].toString();

    // The backend notification carries a human-readable `title` and a `kind`
    // (ADMIN|CLIENT|AGENT|SYSTEM). The model's `type` doubles as the display
    // title, so prefer `title` and fall back to `kind`.
    dto.m_type =
        json["title"].toString();
    if (dto.m_type.isEmpty())
        dto.m_type = json["kind"].toString();

    // The backend flags read state with `isRead` (bool); fold it into the
    // model's `status` so NotificationListModel::unreadCount() stays correct.
    dto.m_status = json["isRead"].toBool() ? "READ" : "UNREAD";

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
    notification->setStatus(m_status);

    return notification;
}
