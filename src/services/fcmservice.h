#ifndef FCMSERVICE_H
#define FCMSERVICE_H

#include <QObject>
#include <QString>

class QTimer;

class FcmService : public QObject
{
    Q_OBJECT

public:
    explicit FcmService(QObject *parent = nullptr);
    ~FcmService();

    Q_INVOKABLE QString getFcmToken();
    Q_INVOKABLE void registerToken();
    Q_INVOKABLE void unregisterToken();

signals:
    void notificationReceived(const QString &title, const QString &body);
    void fcmTokenReceived(const QString &token);

private slots:
    void pollPendingData();

private:
    void sendTokenToBackend(const QString &token);

    QString m_currentToken;
    QTimer *m_pollTimer = nullptr;
};

#endif // FCMSERVICE_H
