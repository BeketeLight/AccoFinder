#include "adminnotificationsrepositoryimpl.h"
#include "services/apiclient.h"
#include <QJsonArray>

AdminNotificationsRepositoryImpl::AdminNotificationsRepositoryImpl(QObject *parent)
    : IAdminNotificationsRepository(parent)
{
}

void AdminNotificationsRepositoryImpl::fetchAnnouncementHistory()
{
    APIClient::instance().get(
        "/notifications/announcements",
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                emit historyFetched(response["data"].toArray().toVariantList());
            } else {
                emit fetchError(response.value("message").toString());
            }
        }, false
    );
}

void AdminNotificationsRepositoryImpl::sendAnnouncement(
    const QString& code, const QString& title, const QString& message)
{
    QJsonObject data;
    data["audience"] = code;
    data["title"] = title;
    data["message"] = message;

    APIClient::instance().post(
        "/notifications/announce",
        data,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                emit announcementSent();
            } else {
                emit sendError(response.value("message").toString());
            }
        }, false
    );
}