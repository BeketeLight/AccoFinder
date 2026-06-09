
#include "apiclient.h"

#include <QNetworkRequest>
#include <QJsonDocument>
#include <QUrl>

APIClient::APIClient(QObject *parent)
    : QObject(parent),
    m_networkManager(new QNetworkAccessManager(this))
{
    connect(
        m_networkManager,
        &QNetworkAccessManager::finished,
        this,
        &APIClient::onReplyFinished
        );
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
    SuccessCallback callback)
{
    sendRequest(
        "GET",
        endpoint,
        QJsonObject(),
        callback
        );
}

void APIClient::post(
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback)
{
    sendRequest(
        "POST",
        endpoint,
        data,
        callback
        );
}

void APIClient::put(
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback)
{
    sendRequest(
        "PUT",
        endpoint,
        data,
        callback
        );
}

void APIClient::del(
    const QString &endpoint,
    SuccessCallback callback)
{
    sendRequest(
        "DELETE",
        endpoint,
        QJsonObject(),
        callback
        );
}

void APIClient::sendRequest(
    const QString &method,
    const QString &endpoint,
    const QJsonObject &data,
    SuccessCallback callback)
{
    QUrl url(m_baseUrl + endpoint);

    QNetworkRequest request(url);

    setupHeaders(request);

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

        m_pendingRequests.insert(
            reply,
            pending
            );
    }
}

void APIClient::setupHeaders(
    QNetworkRequest &request)
{
    request.setHeader(
        QNetworkRequest::ContentTypeHeader,
        "application/json"
        );

    if(!m_authToken.isEmpty())
    {
        request.setRawHeader(
            "Authorization",
            QString("Bearer %1")
                .arg(m_authToken)
                .toUtf8()
            );
    }
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

    bool success =
        reply->error() ==
        QNetworkReply::NoError;
    if(!success)
    {
        emit networkError(
            reply->errorString()
            );

        int statusCode =
            reply->attribute(
                     QNetworkRequest::HttpStatusCodeAttribute
                     ).toInt();

        if(statusCode == 401)
        {
            emit authenticationRequired();
        }

        if(pending.callback)
        {
            pending.callback(
                false,
                QJsonObject()
                );
        }

        reply->deleteLater();
        return;
    }
    QByteArray data =
        reply->readAll();

    QJsonParseError parseError;

    QJsonDocument doc =
        QJsonDocument::fromJson(
            data,
            &parseError
            );
    if(parseError.error !=
        QJsonParseError::NoError)
    {
        emit networkError(
            parseError.errorString()
            );

        if(pending.callback)
        {
            pending.callback(
                false,
                QJsonObject()
                );
        }

        reply->deleteLater();
        return;
    }
    if(pending.callback)
    {
        pending.callback(
            true,
            doc.object()
            );
    }

    reply->deleteLater();
}
