#include "user.h"

User::User(QObject *parent)
    :QObject(parent)
{

}

User::User(const QString &id,
           const QString& firstName,
           const QString& lastName,
           const QString &email,
           const QString &phone,
           const QDateTime &createdAt,
           QObject *parent)
    :m_id(id)
    ,m_firstName(firstName)
    ,m_lastName(lastName)
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
void User::setId(const QString &newId)
{
    m_id = newId;
}

QString User::firstName() const
{
    return m_firstName;
}

void User::setFirstName(const QString &newFirstName)
{
    m_firstName = newFirstName;
}

QString User::lastName() const
{
    return m_lastName;
}

void User::setLastName(const QString &newLastName)
{
    m_lastName = newLastName;
}

// QString User::getName() const
// {
//     return m_name;
// }

// void User::setName(const QString &name)
// {
//     m_name = name;
//     if(getName() == name)
//     {
//         emit profileUpdated();
//     }
// }

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

void User::setCreatedAt(const QDateTime &createdAt)
{

}


