#ifndef USER_H
#define USER_H

#include <QObject>
#include <QString>
#include <QDateTime>

class User : public QObject
{
    Q_OBJECT
public:
    explicit User(QObject *parent = nullptr);
    explicit User(const QString& id,
         const QString& firstName,
         const QString& lastName,
         const QString& email,
         const QString& phone,
         const QDateTime& createdAt,
         QObject *parent = nullptr);
    QString getId() const;

    // QString getName() const;
    // void setName(const QString &name);

    QString getEmail() const;
    void setEmail(const QString &email);

    QString getPhone() const;
    void setPhone(const QString &phone);

    QDateTime getCreatedAt() const;
    void setCreatedAt(const QDateTime &createdAt);

    void setId(const QString &newId);

    QString firstName() const;
    void setFirstName(const QString &newFirstName);

    QString lastName() const;
    void setLastName(const QString &newLastName);

private:
    QString m_id;
    QString m_firstName;
    QString m_lastName;
    QString m_email;
    QString m_phone;
    QDateTime m_createdAt;

signals:
    void profileUpdated();
    void profileCreated();
};

#endif // USER_H
