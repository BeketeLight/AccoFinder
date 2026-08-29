#include "apiclient.h"

#include <QAuthenticator>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QUrl>
#include <QDebug>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>

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

void APIClient::postMultipart(
    const QString &endpoint,
    const QString &filePath,
    const QString &fileFieldName,
    const QString &contentType,
    const QJsonObject &metadata,
    SuccessCallback callback)
{
    QUrl url(m_baseUrl + endpoint);
    QNetworkRequest request(url);
    request.setAttribute(QNetworkRequest::HttpPipeliningAllowedAttribute, false);
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    setupHeadersAllowMultipart(request);

    QFile *file = new QFile(filePath);
    if (!file->open(QIODevice::ReadOnly)) {
        // Build an error response for the callback and emit a network error.
        QString err = QStringLiteral("Could not open file for upload: %1").arg(filePath);
        qWarning() << err;
        emit networkError(err);
        if (callback)
            callback(false, QJsonObject());
        delete file;
        return;
    }

    const QString boundary = "qtformboundary" + QString::number(QDateTime::currentMSecsSinceEpoch());
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    multiPart->setBoundary(boundary.toUtf8());    // Metadata form fields
    for (auto it = metadata.constBegin(); it != metadata.constEnd(); ++it) {
        QHttpPart fieldPart;
        fieldPart.setHeader(QNetworkRequest::ContentDispositionHeader,
                            QStringLiteral("form-data; name=\"%1\"").arg(it.key()));
        QVariant value = it.value().toVariant();
        fieldPart.setBody(value.toString().toUtf8());
        multiPart->append(fieldPart);
    }

    // File part
    QHttpPart filePart;
    const QString fileName = QFileInfo(filePath).fileName();
    filePart.setHeader(
        QNetworkRequest::ContentDispositionHeader,
        QStringLiteral("form-data; name=\"%1\"; filename=\"%2\"").arg(fileFieldName).arg(fileName));
    if (!contentType.isEmpty())
        filePart.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
    file->setParent(multiPart);
    filePart.setBodyDevice(file);
    multiPart->append(filePart);

    qDebug() << "=== Sending Multipart Request ===";
    qDebug() << "Method: POST (multipart/form-data)";
    qDebug() << "URL:" << url.toString();
    qDebug() << "File:" << filePath;
    qDebug() << "Metadata:" << QJsonDocument(metadata).toJson();

    QNetworkReply *reply = m_networkManager->post(request, multiPart);
    multiPart->setParent(reply);

    if (reply) {
        PendingRequest pending;
        pending.callback = callback;
        pending.skipAuth = false;
        m_pendingRequests.insert(reply, pending);
    }
}

void APIClient::sendRequest(
    const QString &method,
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback,
    bool skipAuth,
    bool retried
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
        pending.method = method;
        pending.endpoint = endpoint;
        pending.data = data;
        pending.retried = retried;

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

    if(!skipAuth)
    {
        // Always read the token live so protected (isAuth) endpoints carry the
        // current agent/user session after login, even though APIClient is a
        // long-lived singleton.
        const QString token = m_authToken.isEmpty()
            ? AppSettings::instance().token()
            : m_authToken;
        if(!token.isEmpty())
        {
            request.setRawHeader(
                "Authorization",
                QString("Bearer %1").arg(token).toUtf8());
        }
    }
}

void APIClient::setupHeadersAllowMultipart(
    QNetworkRequest &request,
    bool skipAuth)
{
    // Do NOT set a Content-Type here: QNetworkAccessManager::post(QHttpMultiPart*)
    // sets the proper "multipart/form-data; boundary=..." header automatically.
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("Accept-Language", "en-US,en;q=0.9");
    request.setRawHeader("Cache-Control", "no-cache");

    if(!skipAuth)
    {
        const QString token = m_authToken.isEmpty()
            ? AppSettings::instance().token()
            : m_authToken;
        if(!token.isEmpty())
        {
            request.setRawHeader(
                "Authorization",
                QString("Bearer %1").arg(token).toUtf8());
        }
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
        // session expiry, so only attempt a token refresh for
        // authenticated calls that have not already been retried.
        if(statusCode == 401 && !pending.skipAuth && !pending.retried)
        {
            reply->deleteLater();
            maybeRefreshAndRetry(pending, body);
            return;
        }

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

void APIClient::maybeRefreshAndRetry(
    PendingRequest pending,
    const QJsonObject &originalBody)
{
    // A refresh is already running: queue this request so it is retried
    // once the fresh access token arrives instead of failing immediately.
    if (m_refreshing)
    {
        m_waitingRefresh.push_back(pending);
        return;
    }

    m_refreshing = true;
    startRefresh(pending, originalBody);
}

void APIClient::startRefresh(
    PendingRequest pending,
    const QJsonObject &originalBody)
{
    const QString refreshToken = AppSettings::instance().refreshToken();
    if (refreshToken.isEmpty())
    {
        m_refreshing = false;
        emit authenticationRequired();
        if (pending.callback)
            pending.callback(false, originalBody);
        finishRefreshWaiters(false);
        return;
    }

    QJsonObject payload;
    payload["refreshToken"] = refreshToken;

    // skipAuth = true: the refresh call itself never sends an Authorization
    // header (it uses the refresh token) and must not recurse on a 401.
    sendRequest("POST", "/auth/refresh", payload,
        [this, pending, originalBody](bool ok, const QJsonObject &resp)
        {
            m_refreshing = false;

            const QJsonObject data = resp.value("data").toObject();
            const QString newAccessToken = data.value("accessToken").toString();

            if (!ok || newAccessToken.isEmpty())
            {
                emit authenticationRequired();
                if (pending.callback)
                    pending.callback(false, originalBody);
                finishRefreshWaiters(false);
                return;
            }

            AppSettings::instance().setToken(newAccessToken);
            m_authToken = newAccessToken;

            // Re-issue the original request that hit the 401 with the
            // fresh token (retried = true prevents endless refresh loops).
            sendRequest(pending.method, pending.endpoint, pending.data,
                        pending.callback, pending.skipAuth, true);

            finishRefreshWaiters(true);
        },
        true);
}

void APIClient::finishRefreshWaiters(bool retry)
{
    const QVector<PendingRequest> waiters = m_waitingRefresh;
    m_waitingRefresh.clear();

    for (const PendingRequest &waiter : waiters)
    {
        if (retry)
        {
            sendRequest(waiter.method, waiter.endpoint, waiter.data,
                        waiter.callback, waiter.skipAuth, true);
        }
        else if (waiter.callback)
        {
            waiter.callback(false, QJsonObject());
        }
    }
}