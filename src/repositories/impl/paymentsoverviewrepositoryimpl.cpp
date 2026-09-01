#include "paymentsoverviewrepositoryimpl.h"
#include "services/apiclient.h"

PaymentsOverviewRepositoryImpl::PaymentsOverviewRepositoryImpl(QObject *parent)
    : IPaymentsOverviewRepository(parent)
{
}

void PaymentsOverviewRepositoryImpl::fetchOverview()
{
    APIClient::instance().get(
        "/dashboard/payments",
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                emit overviewFetched(response["data"].toObject());
            } else {
                emit fetchError(response.value("message").toString());
            }
        }, false
    );
}