#ifndef NOTIFICATION_H
#define NOTIFICATION_H

#include <QObject>
#include <QString>

class Notification : public QObject
{
    Q_OBJECT
public:
    explicit Notification(QObject *parent = nullptr);
    Notification(QString& newId, QString& newMessage, QString& newType);
    QString getId() const;
    void setId(const QString &newId);
    QString getMessage() const;
    void setMessage(const QString &newMessage);
    QString getType() const;
    void setType(const QString &newType);

private:
    QString id;
    QString message;
    QString type;
signals:
    void notificationSent();
};

#endif // NOTIFICATION_H
