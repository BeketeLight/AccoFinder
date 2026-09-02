#include "socketioclient.h"

#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include <QSslError>

namespace {
constexpr int kReconnectIntervalMs = 5000;
}

SocketIOClient::SocketIOClient(QObject *parent)
    : QObject(parent)
{
    m_reconnectTimer.setInterval(kReconnectIntervalMs);
    m_reconnectTimer.setSingleShot(false);
    connect(&m_reconnectTimer, &QTimer::timeout, this, &SocketIOClient::onReconnect);

    connect(&m_socket, &QWebSocket::connected, this, &SocketIOClient::onConnected);
    connect(&m_socket, &QWebSocket::disconnected, this, &SocketIOClient::onDisconnected);
    connect(&m_socket, &QWebSocket::textMessageReceived, this, &SocketIOClient::onTextMessageReceived);
    connect(&m_socket, &QWebSocket::sslErrors, this, &SocketIOClient::onSslErrors);
    connect(&m_socket, &QWebSocket::errorOccurred, this, &SocketIOClient::onSocketError);
}

SocketIOClient::~SocketIOClient()
{
    cleanup();
}

void SocketIOClient::cleanup()
{
    m_reconnectTimer.stop();
    if (m_socket.state() != QAbstractSocket::UnconnectedState) {
        m_socket.close();
    }
    m_connected = false;
    m_engineOpen = false;
    m_sid.clear();
}

void SocketIOClient::start(const QString& userId, const QString& userRole, const QString& authToken)
{
    qInfo() << "[SocketIO] start() called, userId:" << userId
            << "role:" << userRole
            << "tokenLen:" << authToken.length()
            << "currentState:" << m_socket.state()
            << "connected:" << m_connected;

    m_userId = userId;
    m_userRole = userRole;
    m_authToken = authToken;
    m_authFailed = false;

    if (m_connected || m_socket.state() == QAbstractSocket::ConnectingState) {
        // Token may have changed — force a fresh connection so the server
        // re-authenticates with the new JWT.
        qInfo() << "[SocketIO] Stopping existing connection to restart with fresh token";
        cleanup();
    }

    const QString baseUrl =
        QStringLiteral("wss://accofinder-trsm.onrender.com/socket.io/?EIO=4&transport=websocket");
    qInfo() << "[SocketIO] Connecting to:" << baseUrl;
    m_socket.open(QUrl(baseUrl));
}

void SocketIOClient::stop()
{
    qInfo() << "[SocketIO] stop() called";
    cleanup();
    emit connectedChanged(false);
}

void SocketIOClient::onConnected()
{
    qInfo() << "[SocketIO] WebSocket connected, waiting for Engine.IO open frame";
}

void SocketIOClient::onDisconnected()
{
    qInfo() << "[SocketIO] WebSocket disconnected, code:" << m_socket.closeCode()
            << "reason:" << m_socket.closeReason();
    const bool wasConnected = m_connected;
    cleanup();

    if (wasConnected)
        emit connectedChanged(false);

    // Keep trying to re-establish a live notification stream while signed in,
    // but NOT after an auth failure — wait for userSessionChanged to restart.
    if (!m_authFailed && !m_userId.isEmpty() && !m_userRole.isEmpty() && !m_authToken.isEmpty()) {
        qInfo() << "[SocketIO] Scheduling reconnect in" << kReconnectIntervalMs << "ms";
        m_reconnectTimer.start();
    }
}

void SocketIOClient::onSocketError(QAbstractSocket::SocketError error)
{
    qWarning() << "[SocketIO] WebSocket error:" << error << m_socket.errorString();
    emit errorOccurred(m_socket.errorString());
}

void SocketIOClient::onSslErrors(const QList<QSslError>& errors)
{
    qWarning() << "[SocketIO] SSL errors:" << errors;
    m_socket.ignoreSslErrors();
}

void SocketIOClient::onReconnect()
{
    if (m_authFailed)
        return;
    if (m_socket.state() != QAbstractSocket::UnconnectedState)
        return;
    qInfo() << "[SocketIO] Reconnecting...";
    start(m_userId, m_userRole, m_authToken);
}

void SocketIOClient::sendEngineFrame(const QString& frame)
{
    if (m_socket.state() == QAbstractSocket::ConnectedState)
        m_socket.sendTextMessage(frame);
}

void SocketIOClient::onTextMessageReceived(const QString& message)
{
    // Engine.IO frames: "0" open, "2" ping, "3" pong, "4" message,
    // "6" upgrade. Socket.IO packets are nested: "40" CONNECT, "42" EVENT.
    if (message.isEmpty())
        return;

    qDebug() << "[SocketIO] Recv:" << message.left(200);

    const QChar type = message.at(0);
    if (type == QLatin1Char('0')) {
        m_engineOpen = true;
        const QString payload = message.mid(1);
        const QJsonObject openObj = QJsonDocument::fromJson(payload.toUtf8()).object();
        m_sid = openObj.value(QStringLiteral("sid")).toString();
        qInfo() << "[SocketIO] Engine.IO open, sid:" << m_sid;
        sendConnect();
        return;
    }
    if (type == QLatin1Char('2')) {
        sendEngineFrame(QStringLiteral("3"));
        return;
    }
    if (type == QLatin1Char('3')) {
        return;
    }
    if (type == QLatin1Char('4')) {
        handleSocketPayload(message.mid(1));
        return;
    }
    if (type == QLatin1Char('1')) {
        qInfo() << "[SocketIO] Engine.IO close received";
        return;
    }
}

void SocketIOClient::sendConnect()
{
    QJsonObject auth;
    auth.insert(QStringLiteral("token"), m_authToken);
    const QByteArray json = QJsonDocument(auth).toJson(QJsonDocument::Compact);
    qInfo() << "[SocketIO] Sending Socket.IO CONNECT with auth token";
    sendEngineFrame(QStringLiteral("40") + QString::fromUtf8(json));
}

void SocketIOClient::handleSocketPayload(const QString& payload)
{
    // Socket.IO packet types: 0=CONNECT, 1=DISCONNECT, 2=EVENT, 3=ACK,
    // 4=CONNECT_ERROR, 5=ACK, 6=BINARY_EVENT, 7=BINARY_ACK
    if (payload.isEmpty())
        return;

    const QChar packetType = payload.at(0);

    if (packetType == QLatin1Char('0')) {
        qInfo() << "[SocketIO] CONNECT acknowledged by server — connection established";
        if (!m_connected) {
            m_connected = true;
            emit connectedChanged(true);
        }
        return;
    }

    if (packetType == QLatin1Char('4')) {
        // CONNECT_ERROR from server (e.g. auth failure)
        const QString errorData = payload.mid(1).trimmed();
        qWarning() << "[SocketIO] CONNECT_ERROR from server:" << errorData;
        emit errorOccurred(QStringLiteral("Socket.IO rejected: %1").arg(errorData));
        // Auth failed — don't auto-reconnect.  Wait for userSessionChanged
        // (triggered by a fresh token) to restart the connection.
        m_authFailed = true;
        m_reconnectTimer.stop();
        m_socket.close();
        return;
    }

    if (packetType == QLatin1Char('2')) {
        const QString data = payload.mid(1).trimmed();
        const QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
        if (!doc.isArray())
            return;
        const QJsonArray arr = doc.array();
        if (arr.isEmpty())
            return;
        const QString eventName = arr.at(0).toString();
        qInfo() << "[SocketIO] Received event:" << eventName;
        if (eventName == QStringLiteral("notification")) {
            emit notificationReceived();
        }
        return;
    }
}
