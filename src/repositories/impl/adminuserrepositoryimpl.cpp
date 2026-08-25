#include "adminuserrepositoryimpl.h"
#include "services/apiclient.h"
#include <QJsonObject>
#include <QJsonArray>

AdminUserRepositoryImpl::AdminUserRepositoryImpl(QObject *parent)
    : IAdminUserRepository(parent)
{
}

void AdminUserRepositoryImpl::getUsers()
{
    APIClient::instance().get(
        "api/users/",
        [this](bool success, const QJsonObject& response)
        {
            QList<User*> users;
            if (success && response.contains("data")) {
                QJsonArray dataArray = response["data"].toArray();
                for (const QJsonValue& value : std::as_const(dataArray)) {
                    UserDto dto = UserDto::fromJson(value.toObject());
                    users.append(dto.toDomainModel());
                }
                emit usersLoaded(users);
            } else {
                emit userError(response.value("message").toString());
            }
        }
    );
}

void AdminUserRepositoryImpl::getUserById(const QString &userId)
{
    APIClient::instance().get(
        "api/users/" + userId,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                UserDto dto = UserDto::fromJson(response["data"].toObject());
                emit userLoaded(dto.toDomainModel());
            } else {
                emit userError(response.value("message").toString());
            }
        }
    );
}

void AdminUserRepositoryImpl::updateUserRole(const QString &userId, const QString &role)
{
    QJsonObject payload;
    payload["role"] = role;

    APIClient::instance().patch(
        "api/users/" + userId + "/role",
        payload,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                UserDto dto = UserDto::fromJson(response["data"].toObject());
                emit userUpdated(dto.toDomainModel());
            } else {
                emit userError(response.value("message").toString());
            }
        }
    );
}

void AdminUserRepositoryImpl::setAccountActive(const QString &userId, bool active)
{
    QJsonObject payload;
    payload["isActive"] = active;

    APIClient::instance().patch(
        "api/users/" + userId + "/status",
        payload,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                UserDto dto = UserDto::fromJson(response["data"].toObject());
                emit userUpdated(dto.toDomainModel());
            } else {
                emit userError(response.value("message").toString());
            }
        }
    );
}
