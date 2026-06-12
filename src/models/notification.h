#ifndef NOTIFICATION_H
#define NOTIFICATION_H

#include <QObject>
#include <QString>

class Notification : public QObject
{
    Q_OBJECT
public:
    Notification();
    explicit Notification(const QString& id,
                          const QString& message,
                          const QString& type,
                          const QString& status,
                          QObject *parent = nullptr);
    QString getId() const;
    QString getMessage() const;
    QString getType() const;


    void setId(const QString &newId);
    void setMessage(const QString &newMessage);
    void setType(const QString &newType);

    QString status() const;
    void setStatus(const QString &newStatus);

private:
    QString m_id;
    QString m_message;
    QString m_type;
    QString m_status;
signals:
    void notificationCreated();
    void notificationSent();
};

#endif // NOTIFICATION_H
