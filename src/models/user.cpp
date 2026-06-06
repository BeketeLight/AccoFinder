#include "user.h"

User::User(QObject *parent)
    : QObject{parent}
{}

User::User(QString &newId, QString &newName, QString &newEmail, QString &newPhone, QDateTime &newCreatedAt)
{
    id = newId;
    name = newName;
    email = newEmail;
    phone = newPhone;
    createdAt = newCreatedAt;

    emit profileCreated();
}

QString User::getId() const
{
    return id;
}

void User::setId(const QString &newId)
{
    id = newId;
    if (getId() == newId)
    {
        emit profileUpdated();
    }
}

QString User::getName() const
{
    return name;
}

void User::setName(const QString &newName)
{
    name = newName;
    if(getName() == newName)
    {
        emit profileUpdated();
    }
}

QString User::getEmail() const
{
    return email;
}

void User::setEmail(const QString &newEmail)
{
    email = newEmail;
    if (getEmail() == newEmail)
    {
        emit profileUpdated();
    }
}

QString User::getPhone() const
{
    return phone;
}

void User::setPhone(const QString &newPhone)
{
    phone = newPhone;
    if(getPhone() == newPhone)
    {
        emit profileUpdated();
    }
}

QDateTime User::getCreatedAt() const
{
    return createdAt;
}

void User::setCreatedAt(const QDateTime &newCreatedAt)
{
    createdAt = newCreatedAt;
    if (getCreatedAt() == newCreatedAt)
    {
        emit profileUpdated();
    }
}
