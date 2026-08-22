#ifndef USER_H
#define USER_H

#include <QObject>
#include <QString>
#include <QDateTime>

class User : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ getId WRITE setId NOTIFY profileUpdated)
    Q_PROPERTY(QString firstName READ firstName WRITE setFirstName NOTIFY profileUpdated)
    Q_PROPERTY(QString lastName READ lastName WRITE setLastName NOTIFY profileUpdated)
    Q_PROPERTY(QString fullName READ getFullName NOTIFY profileUpdated)
    Q_PROPERTY(QString email READ getEmail WRITE setEmail NOTIFY profileUpdated)
    Q_PROPERTY(QString phone READ getPhone WRITE setPhone NOTIFY profileUpdated)
    Q_PROPERTY(QString residentialAddress READ getResidentialAddress WRITE setResidentialAddress NOTIFY profileUpdated)
    Q_PROPERTY(QString role READ getRole WRITE setRole NOTIFY profileUpdated)
    Q_PROPERTY(QDateTime createdAt READ getCreatedAt WRITE setCreatedAt NOTIFY profileUpdated)

public:
    explicit User(QObject *parent = nullptr);

    // Original constructor (for full user data)
    explicit User(const QString& id,
                  const QString& firstName,
                  const QString& lastName,
                  const QString& email,
                  const QString& phone,
                  const QDateTime& createdAt,
                  QObject *parent = nullptr);

    // New constructor for login/register responses (backend sends 'name' as single field)
    explicit User(const QString& id,
                  const QString& fullName,
                  const QString& email,
                  const QString& residentialAddress,
                  const QString& role,
                  QObject *parent = nullptr);

    // Getters
    QString getId() const;
    QString firstName() const;
    QString lastName() const;
    QString getFullName() const;
    QString getEmail() const;
    QString getPhone() const;
    QString getResidentialAddress() const;
    QString getRole() const;
    QDateTime getCreatedAt() const;

    // Setters
    void setId(const QString &newId);
    void setFirstName(const QString &newFirstName);
    void setLastName(const QString &newLastName);
    void setEmail(const QString &newEmail);
    void setPhone(const QString &newPhone);
    void setResidentialAddress(const QString &newResidentialAddress);
    void setRole(const QString &newRole);
    void setCreatedAt(const QDateTime &newCreatedAt);

    // Convenience method to set full name (splits into first and last)
    void setFullName(const QString &fullName);

signals:
    void profileUpdated();
    void profileCreated();

private:
    QString m_id;
    QString m_firstName;
    QString m_lastName;
    QString m_email;
    QString m_phone;
    QString m_residentialAddress;
    QString m_role;
    QDateTime m_createdAt;
};

#endif // USER_H