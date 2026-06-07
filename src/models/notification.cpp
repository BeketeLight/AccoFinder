#include "notification.h"

Notification::Notification(const QString &id,
                           const QString &message,
                           const QString &type,
                           QObject *parent)
    :m_id(id)
    ,m_message(message)
    ,m_type(type)
    ,QObject(parent)
{
    emit notificationCreated();

}

QString Notification::getId() const
{
    return m_id;
}


QString Notification::getMessage() const
{
    return m_message;
}


QString Notification::getType() const
{
    return m_type;
}


