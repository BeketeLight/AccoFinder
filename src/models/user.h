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
    User(QString& newId, QString& newName, QString& newEmail, QString& newPhone, QDateTime& newCreatedAt);
    QString getId() const;
    void setId(const QString &newId);

    QString getName() const;
    void setName(const QString &newName);

    QString getEmail() const;
    void setEmail(const QString &newEmail);

    QString getPhone() const;
    void setPhone(const QString &newPhone);

    QDateTime getCreatedAt() const;
    void setCreatedAt(const QDateTime &newCreatedAt);

private:
    QString id;
    QString name;
    QString email;
    QString phone;
    QDateTime createdAt;

signals:

    // this signal will be emitted whenever user profile changes
    void profileUpdated();
    // this for when the profileis created
    void profileCreated();
};

#endif // USER_H
