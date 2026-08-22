#include "apiclient.h"

#include <QAuthenticator>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QUrl>
#include <QDebug>

APIClient::APIClient(QObject *parent)
    : QObject(parent),
    m_networkManager(new QNetworkAccessManager(this))
    ,m_authToken(AppSettings::instance().token())
    ,m_baseUrl("https://accofinder-trsm.onrender.com/api")
{
    // Enable cookie support
    m_networkManager->setCookieJar(new QNetworkCookieJar(this));

    connect(
        m_networkManager,
        &QNetworkAccessManager::finished,
        this,
        &APIClient::onReplyFinished
        );

    // Login/register return HTTP 401 with a JSON body. If Qt treats that as
    // an HTTP auth challenge it hides the payload behind
    // "Host requires authentication". Leave the authenticator empty.
    connect(
        m_networkManager,
        &QNetworkAccessManager::authenticationRequired,
        this,
        [](QNetworkReply *, QAuthenticator *) {
        }
        );
}

APIClient& APIClient::instance()
{
    static APIClient instance;
    return instance;
}

void APIClient::setBaseUrl(const QString &url)
{
    m_baseUrl = url;
}

void APIClient::setAuthToken(const QString &token)
{
    m_authToken = token;
}

void APIClient::get(
    const QString &endpoint,
    SuccessCallback callback,
    bool skipAuth)
{
    sendRequest(
        "GET",
        endpoint,
        QJsonObject(),
        callback,
        skipAuth
        );
}

void APIClient::post(
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback,
    bool skipAuth)
{
    sendRequest(
        "POST",
        endpoint,
        data,
        callback,
        skipAuth
        );
}

void APIClient::put(
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback,
    bool skipAuth)
{
    sendRequest(
        "PUT",
        endpoint,
        data,
        callback,
        skipAuth
        );
}

void APIClient::patch(
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback,
    bool skipAuth)
{
    sendRequest
        (
            "PATCH",
            endpoint,
            data,
            callback,
            skipAuth
            );

}

void APIClient::del(
    const QString &endpoint,
    SuccessCallback callback,
    bool skipAuth)
{
    sendRequest(
        "DELETE",
        endpoint,
        QJsonObject(),
        callback,
        skipAuth
        );
}

void APIClient::sendRequest(
    const QString &method,
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback,
    bool skipAuth
    )
{
    QUrl url(m_baseUrl + endpoint);

    QNetworkRequest request(url);

    // Force HTTP/1.1 instead of HTTP/2 (Qt 6 compatible)
    request.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, false);
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);

    setupHeaders(request, skipAuth);

    // Debug output
    qDebug() << "=== Sending Request ===";
    qDebug() << "Method:" << method;
    qDebug() << "URL:" << url.toString();
    qDebug() << "Skip Auth:" << skipAuth;
    qDebug() << "Headers:";
    for (const auto& header : request.rawHeaderList()) {
        qDebug() << "  " << header << ":" << request.rawHeader(header);
    }
    if (method == "POST" || method == "PUT" || method == "PATCH") {
        qDebug() << "Body:" << QJsonDocument(data).toJson();
    }

    QNetworkReply* reply = nullptr;

    if(method == "GET")
    {
        reply = m_networkManager->get(request);
    }
    else if(method == "POST")
    {
        QJsonDocument doc(data);

        reply = m_networkManager->post(
            request,
            doc.toJson()
            );
    }
    else if(method == "PATCH")
    {
        QJsonDocument doc(data);

        reply = m_networkManager->sendCustomRequest(
            request,
            "PATCH",
            doc.toJson()
            );
    }
    else if(method == "PUT")
    {
        QJsonDocument doc(data);

        reply = m_networkManager->put(
            request,
            doc.toJson()
            );
    }
    else if(method == "DELETE")
    {
        reply = m_networkManager->deleteResource(
            request
            );
    }

    if(reply)
    {
        PendingRequest pending;
        pending.callback = callback;
        pending.skipAuth = skipAuth;

        m_pendingRequests.insert(
            reply,
            pending
            );
    }
}

void APIClient::setupHeaders(
    QNetworkRequest &request,
    bool skipAuth)
{
    request.setHeader(
        QNetworkRequest::ContentTypeHeader,
        "application/json"
        );

    // Add standard headers
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("Accept-Language", "en-US,en;q=0.9");
    request.setRawHeader("Cache-Control", "no-cache");

    if(!skipAuth && !m_authToken.isEmpty())
    {
        request.setRawHeader(
            "Authorization",
            QString("Bearer %1")
                .arg(m_authToken)
                .toUtf8()
            );
    }
}

QString APIClient::errorMessageFromBody(const QJsonObject &body)
{
    const QString message =
        body.value(QStringLiteral("message")).toString().trimmed();
    if (!message.isEmpty())
        return message;

    const QString error =
        body.value(QStringLiteral("error")).toString().trimmed();
    if (!error.isEmpty())
        return error;

    return {};
}

void APIClient::onReplyFinished(
    QNetworkReply *reply)
{
    if(!m_pendingRequests.contains(reply))
    {
        reply->deleteLater();
        return;
    }

    PendingRequest pending =
        m_pendingRequests.take(reply);

    const int statusCode =
        reply->attribute(
                 QNetworkRequest::HttpStatusCodeAttribute
                 ).toInt();

    // Always read the body first. Qt maps HTTP 401 to
    // AuthenticationRequiredError and errorString() becomes
    // "Host requires authentication", but the backend still sends JSON:
    // {"success": false, "message": "Invalid email or password."}
    const QByteArray data = reply->readAll();

    qDebug() << "=== Response Received ===";
    qDebug() << "Status Code:" << statusCode;
    qDebug() << "Error:" << reply->errorString();
    qDebug() << "Headers:";
    for (const auto& header : reply->rawHeaderList()) {
        qDebug() << "  " << header << ":" << reply->rawHeader(header);
    }
    qDebug() << "Response Data:" << data;

    QJsonParseError parseError;
    const QJsonDocument doc =
        QJsonDocument::fromJson(data, &parseError);
    const QJsonObject body =
        (parseError.error == QJsonParseError::NoError)
            ? doc.object()
            : QJsonObject();

    const bool httpOk =
        reply->error() == QNetworkReply::NoError;

    if(!httpOk)
    {
        qDebug() << "Actual backend error:" << data;

        const QString backendMessage = errorMessageFromBody(body);
        const QString message = !backendMessage.isEmpty()
            ? backendMessage
            : reply->errorString();

        emit networkError(message);

        // A failed login/register also returns 401. That is not a
        // session expiry, so only signal it for authenticated calls.
        if(statusCode == 401 && !pending.skipAuth)
        {
            emit authenticationRequired();
        }

        if(pending.callback)
        {
            pending.callback(false, body);
        }

        reply->deleteLater();
        return;
    }

    if(parseError.error != QJsonParseError::NoError)
    {
        emit networkError(parseError.errorString());

        if(pending.callback)
        {
            pending.callback(false, QJsonObject());
        }

        reply->deleteLater();
        return;
    }

    if(pending.callback)
    {
        pending.callback(true, body);
    }

    reply->deleteLater();
}