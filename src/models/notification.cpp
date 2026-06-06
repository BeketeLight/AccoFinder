#include "notification.h"

Notification::Notification(QObject *parent)
    : QObject{parent}
{}

Notification::Notification(QString& newId, QString& newMessage, QString& newType)
{}

QString Notification::getId() const
{
    return id;
}

void Notification::setId(const QString &newId)
{
    id = newId;
}

QString Notification::getMessage() const
{
    return message;
}

void Notification::setMessage(const QString &newMessage)
{
    message = newMessage;
}

QString Notification::getType() const
{
    return type;
}

void Notification::setType(const QString &newType)
{
    type = newType;
}
