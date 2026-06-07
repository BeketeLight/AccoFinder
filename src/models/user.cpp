#include "user.h"

User::User(const QString &id,
           const QString &name,
           const QString &email,
           const QString &phone,
           const QDateTime &createdAt,
           QObject *parent)
    :m_id(id)
    ,m_name(name)
    ,m_email(email)
    ,m_createdAt(createdAt)
    ,QObject(parent)
{
    emit profileCreated();
}

QString User::getId() const
{
    return m_id;
}



QString User::getName() const
{
    return m_name;
}

void User::setName(const QString &name)
{
    m_name = name;
    if(getName() == name)
    {
        emit profileUpdated();
    }
}

QString User::getEmail() const
{
    return m_email;
}

void User::setEmail(const QString &email)
{
    m_email = email;
    if (getEmail() == email)
    {
        emit profileUpdated();
    }
}

QString User::getPhone() const
{
    return m_phone;
}

void User::setPhone(const QString &phone)
{
    m_phone = phone;
    if(getPhone() == phone)
    {
        emit profileUpdated();
    }
}

QDateTime User::getCreatedAt() const
{
    return m_createdAt;
}
