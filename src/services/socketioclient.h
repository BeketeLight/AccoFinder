#ifndef SOCKETIOCLIENT_H
#define SOCKETIOCLIENT_H

#include <QObject>
#include <QWebSocket>
#include <QTimer>

// Minimal Socket.IO-over-WebSocket client (Engine.IO v4 + Socket.IO protocol)
// used to receive realtime notifications.
//
// The backend restricts Socket.IO to the websocket transport and emits a
// "notification" event onto rooms named "user:<id>" and "role:<role>". This
// client connects, joins both rooms for the signed-in user and emits
// notificationReceived whenever a notification arrives, so the UI can refresh
// immediately instead of waiting for the 30s poll.
class SocketIOClient : public QObject
{
    Q_OBJECT
public:
    explicit SocketIOClient(QObject *parent = nullptr);
    ~SocketIOClient() override;

    Q_INVOKABLE void start(const QString& userId, const QString& userRole, const QString& authToken);
    Q_INVOKABLE void stop();
    Q_INVOKABLE bool isConnected() const { return m_connected; }

signals:
    void connectedChanged(bool connected);
    void notificationReceived();
    void errorOccurred(const QString& message);

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString& message);
    void onSslErrors(const QList<QSslError>& errors);
    void onSocketError(QAbstractSocket::SocketError error);
    void onReconnect();

private:
    void sendEngineFrame(const QString& frame);
    void sendConnect();
    void handleSocketPayload(const QString& payload);
    void cleanup();

    QWebSocket m_socket;
    QTimer m_reconnectTimer;
    QString m_userId;
    QString m_userRole;
    QString m_authToken;
    bool m_connected = false;
    bool m_engineOpen = false;
    bool m_authFailed = false;
    QString m_sid;
};

#endif // SOCKETIOCLIENT_H