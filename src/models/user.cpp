#include "user.h"

User::User(QObject *parent)
    : QObject{parent}
{}

QString User::getId() const
{
    return id;
}

void User::setId(const QString &newId)
{
    id = newId;
}

QString User::getName() const
{
    return name;
}

void User::setName(const QString &newName)
{
    name = newName;
}

QString User::getEmail() const
{
    return email;
}

void User::setEmail(const QString &newEmail)
{
    email = newEmail;
}

QString User::getPhone() const
{
    return phone;
}

void User::setPhone(const QString &newPhone)
{
    phone = newPhone;
}

QDateTime User::getCreatedAt() const
{
    return createdAt;
}

void User::setCreatedAt(const QDateTime &newCreatedAt)
{
    createdAt = newCreatedAt;
}
