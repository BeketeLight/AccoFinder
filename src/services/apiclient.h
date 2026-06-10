
#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <functional>
#include <QMap>
#include "core/utils/appsettings.h"

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
        SuccessCallback callback
        );

    void post(
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback
        );

    void put(
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback
        );
    void patch(
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback
        );


    void del(
        const QString& endpoint,
        SuccessCallback callback
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
    };

    QNetworkAccessManager* m_networkManager;

    QString m_baseUrl;
    QString m_authToken;

    QMap<QNetworkReply*, PendingRequest> m_pendingRequests;

    void sendRequest(
        const QString& method,
        const QString& endpoint,
        const QJsonObject& data,
        SuccessCallback callback
        );

    void setupHeaders(QNetworkRequest& request);
};

#endif
