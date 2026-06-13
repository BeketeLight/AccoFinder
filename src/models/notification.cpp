#include "notification.h"

Notification::Notification()
{

}

Notification::Notification(const QString &id,
                           const QString &message,
                           const QString &type,
                           const QString &status,
                           QObject *parent)
    :m_id(id)
    ,m_message(message)
    ,m_type(type)
    ,m_status(status)
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

void Notification::setId(const QString &newId)
{
    m_id = newId;
}

void Notification::setMessage(const QString &newMessage)
{
    m_message = newMessage;
}

void Notification::setType(const QString &newType)
{
    m_type = newType;
}

QString Notification::status() const
{
    return m_status;
}

void Notification::setStatus(const QString &newStatus)
{
    m_status = newStatus;
}


