#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <functional>
#include <QMap>
#include "core/utils/appsettings.h"
#include <QNetworkCookieJar>

class APIClient : public QObject
{
    Q_OBJECT

public:

    using SuccessCallback =
        std::function<void(bool success,
                           const QJsonObject& response)>;
    static APIClient& instance();

    void setBaseUrl(const QString& url);
    void setAuthToken(const QString& token);

    void get(
        const QString& endpoint,
        SuccessCallback callback,
        bool skipAuth = false
        );

    void post(
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback,
        bool skipAuth = false
        );

    void put(
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback,
        bool skipAuth = false
        );

    void patch(
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback,
        bool skipAuth = false
        );

    void del(
        const QString& endpoint,
        SuccessCallback callback,
        bool skipAuth = false
        );

signals:

    void networkError(const QString& message);
    void authenticationRequired();

private slots:

    void onReplyFinished(QNetworkReply* reply);

private:
    explicit APIClient(QObject *parent = nullptr);
    APIClient(const APIClient&) = delete;
    APIClient& operator=(const APIClient&) = delete;

    struct PendingRequest
    {
        SuccessCallback callback;
        bool skipAuth = false;
    };

    QNetworkAccessManager* m_networkManager;

    QString m_baseUrl;
    QString m_authToken;

    QMap<QNetworkReply*, PendingRequest> m_pendingRequests;

    void sendRequest(
        const QString& method,
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback,
        bool skipAuth = false
        );

    void setupHeaders(QNetworkRequest& request, bool skipAuth = false);
    static QString errorMessageFromBody(const QJsonObject& body);
};

#endif