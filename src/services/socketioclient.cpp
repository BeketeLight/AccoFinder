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
}

SocketIOClient::~SocketIOClient()
{
    m_reconnectTimer.stop();
    m_socket.close();
}

void SocketIOClient::start(const QString& userId, const QString& userRole, const QString& authToken)
{
    m_userId = userId;
    m_userRole = userRole;
    m_authToken = authToken;
    if (m_connected || m_socket.state() == QAbstractSocket::ConnectingState)
        return;

    const QString baseUrl =
        QStringLiteral("wss://accofinder-trsm.onrender.com/socket.io/?EIO=4&transport=websocket");
    m_socket.open(QUrl(baseUrl));
}

void SocketIOClient::stop()
{
    m_reconnectTimer.stop();
    m_socket.close();
    m_connected = false;
    m_engineOpen = false;
    m_sid.clear();
    emit connectedChanged(false);
}

void SocketIOClient::onConnected()
{
    // Engine.IO open is signalled by an "0{...}" frame; wait for it before
    // sending the Socket.IO CONNECT.
}

void SocketIOClient::onDisconnected()
{
    m_connected = false;
    m_engineOpen = false;
    m_sid.clear();
    emit connectedChanged(false);

    // Keep trying to re-establish a live notification stream while signed in.
    if (!m_userId.isEmpty() && !m_userRole.isEmpty())
        m_reconnectTimer.start();
}

void SocketIOClient::onSslErrors(const QList<QSslError>& errors)
{
    qWarning() << "Socket.IO SSL errors:" << errors;
    m_socket.ignoreSslErrors();
}

void SocketIOClient::onReconnect()
{
    if (m_socket.state() != QAbstractSocket::UnconnectedState)
        return;
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
    if (!message.isEmpty()) {
        const QChar type = message.at(0);
        if (type == QLatin1Char('0')) {
            m_engineOpen = true;
            // Extract sid from the open payload, then send Socket.IO CONNECT.
            const QString payload = message.mid(1);
            const QJsonObject openObj = QJsonDocument::fromJson(payload.toUtf8()).object();
            m_sid = openObj.value(QStringLiteral("sid")).toString();
            sendConnect();
            return;
        }
        if (type == QLatin1Char('2')) {
            // Engine.IO ping -> reply pong.
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
            return; // close
        }
    }
}

void SocketIOClient::sendConnect()
{
    // Socket.IO CONNECT with the auth token. The server verifies it, attaches
    // the user, and auto-joins the user:<id> / role:<role> rooms itself, so the
    // client never picks its own room ids.
    QJsonObject auth;
    auth.insert(QStringLiteral("token"), m_authToken);
    const QByteArray json = QJsonDocument(auth).toJson(QJsonDocument::Compact);
    sendEngineFrame(QStringLiteral("40") + QString::fromUtf8(json));
}

void SocketIOClient::handleSocketPayload(const QString& payload)
{
    // Socket.IO packet: "0" CONNECT, "1" DISCONNECT, "2" EVENT, ...
    if (payload.startsWith(QLatin1Char('0'))) {
        // Server acknowledged the CONNECT (and has auto-joined our rooms).
        if (!m_connected) {
            m_connected = true;
            emit connectedChanged(true);
        }
        return;
    }
    if (payload.startsWith(QLatin1Char('2'))) {
        // EVENT: ["eventName", data...]
        const QString data = payload.mid(1).trimmed();
        const QJsonDocument doc = QJsonDocument::fromJson(data.toUtf8());
        if (!doc.isArray())
            return;
        const QJsonArray arr = doc.array();
        if (arr.isEmpty())
            return;
        const QString eventName = arr.at(0).toString();
        if (eventName == QStringLiteral("notification")) {
            emit notificationReceived();
        }
        return;
    }
}