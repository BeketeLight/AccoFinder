#include "user.h"
#include <QDebug>

User::User(QObject *parent)
    : QObject(parent)
    , m_createdAt(QDateTime::currentDateTime())
{
    emit profileCreated();
}

// Original constructor (for full user data)
User::User(const QString &id,
           const QString &firstName,
           const QString &lastName,
           const QString &email,
           const QString &phone,
           const QDateTime &createdAt,
           QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_firstName(firstName)
    , m_lastName(lastName)
    , m_email(email)
    , m_phone(phone)
    , m_createdAt(createdAt)
{
    emit profileCreated();
}

// New constructor for login/register responses
User::User(const QString &id,
           const QString &fullName,
           const QString &email,
           const QString &residentialAddress,
           const QString &role,
           QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_email(email)
    , m_residentialAddress(residentialAddress)
    , m_role(role)
    , m_createdAt(QDateTime::currentDateTime())
{
    // Split full name into first and last name
    setFullName(fullName);
    emit profileCreated();
}

// Getters
QString User::getId() const
{
    return m_id;
}

QString User::firstName() const
{
    return m_firstName;
}

QString User::lastName() const
{
    return m_lastName;
}

QString User::getFullName() const
{
    if (m_firstName.isEmpty() && m_lastName.isEmpty()) {
        return "";
    }
    return m_firstName + " " + m_lastName;
}

QString User::getEmail() const
{
    return m_email;
}

QString User::getPhone() const
{
    return m_phone;
}

QString User::getResidentialAddress() const
{
    return m_residentialAddress;
}

QString User::getRole() const
{
    return m_role;
}

QDateTime User::getCreatedAt() const
{
    return m_createdAt;
}

// Setters
void User::setId(const QString &newId)
{
    if (m_id == newId)
        return;
    m_id = newId;
    emit profileUpdated();
}

void User::setFirstName(const QString &newFirstName)
{
    if (m_firstName == newFirstName)
        return;
    m_firstName = newFirstName;
    emit profileUpdated();
}

void User::setLastName(const QString &newLastName)
{
    if (m_lastName == newLastName)
        return;
    m_lastName = newLastName;
    emit profileUpdated();
}

void User::setFullName(const QString &fullName)
{
    if (fullName.isEmpty()) {
        m_firstName = "";
        m_lastName = "";
        emit profileUpdated();
        return;
    }

    QStringList nameParts = fullName.trimmed().split(" ", Qt::SkipEmptyParts);
    if (nameParts.isEmpty()) {
        m_firstName = "";
        m_lastName = "";
    } else if (nameParts.size() == 1) {
        m_firstName = nameParts.first();
        m_lastName = "";
    } else {
        m_firstName = nameParts.first();
        // Join the rest as last name
        nameParts.removeFirst();
        m_lastName = nameParts.join(" ");
    }
    emit profileUpdated();
}

void User::setEmail(const QString &newEmail)
{
    if (m_email == newEmail)
        return;
    m_email = newEmail;
    emit profileUpdated();
}

void User::setPhone(const QString &newPhone)
{
    if (m_phone == newPhone)
        return;
    m_phone = newPhone;
    emit profileUpdated();
}

void User::setResidentialAddress(const QString &newResidentialAddress)
{
    if (m_residentialAddress == newResidentialAddress)
        return;
    m_residentialAddress = newResidentialAddress;
    emit profileUpdated();
}

void User::setRole(const QString &newRole)
{
    if (m_role == newRole)
        return;
    m_role = newRole;
    emit profileUpdated();
}

void User::setCreatedAt(const QDateTime &newCreatedAt)
{
    if (m_createdAt == newCreatedAt)
        return;
    m_createdAt = newCreatedAt;
    emit profileUpdated();
}