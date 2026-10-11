#include "settingsrepositoryimpl.h"
#include "services/apiclient.h"
#include <QJsonObject>

SettingsRepositoryImpl::SettingsRepositoryImpl(QObject *parent)
    : ISettingsRepository(parent)
{
}

void SettingsRepositoryImpl::fetchPlatformSettings()
{
    // The platform settings are public, so this runs on startup before the
    // user is signed in and carries no auth token that may not exist yet.
    APIClient::instance().get(
        "/settings/platform",
        [this](bool success, const QJsonObject& response)
        {
            if (!success) {
                emit settingsError(response.value("message").toString());
                return;
            }

            const QJsonObject data = response.value("data").toObject();
            emit platformSettingsLoaded(data.value("bookingFee").toDouble(),
                                        data.value("commissionRate").toDouble());
        },
        true
    );
}

void SettingsRepositoryImpl::updatePlatformSettings(double bookingFee, double commissionRate)
{
    QJsonObject payload;
    payload["bookingFee"] = bookingFee;
    payload["commissionRate"] = commissionRate;

    APIClient::instance().put(
        "/settings/platform",
        payload,
        [this](bool success, const QJsonObject& response)
        {
            if (!success) {
                emit settingsError(response.value("message").toString());
                return;
            }

            const QJsonObject data = response.value("data").toObject();
            emit platformSettingsUpdated(data.value("bookingFee").toDouble(),
                                         data.value("commissionRate").toDouble());
        },
        false
    );
}
