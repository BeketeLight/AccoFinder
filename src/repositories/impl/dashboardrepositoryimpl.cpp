#include "dashboardrepositoryimpl.h"
#include "services/apiclient.h"

DashboardRepositoryImpl::DashboardRepositoryImpl(QObject *parent)
    : IDashboardRepository(parent)
{
}

void DashboardRepositoryImpl::fetchStats()
{
    APIClient::instance().get(
        "/dashboard/stats",
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                emit statsFetched(response["data"].toObject());
            } else {
                emit fetchError(response.value("message").toString());
            }
        }, false
    );
}