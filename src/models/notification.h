#ifndef NOTIFICATION_H
#define NOTIFICATION_H

#include <QObject>
#include <QString>

class Notification : public QObject
{
    Q_OBJECT
public:
    explicit Notification(const QString& id,
                          const QString& message,
                          const QString& type,
                          QObject *parent = nullptr);
    QString getId() const;
    QString getMessage() const;
    QString getType() const;


private:
    QString m_id;
    QString m_message;
    QString m_type;
signals:
    void notificationCreated();
    void notificationSent();
};

#endif // NOTIFICATION_H
