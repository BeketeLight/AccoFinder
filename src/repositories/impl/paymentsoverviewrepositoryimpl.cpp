#include "paymentsoverviewrepositoryimpl.h"
#include "services/apiclient.h"

PaymentsOverviewRepositoryImpl::PaymentsOverviewRepositoryImpl(QObject *parent)
    : IPaymentsOverviewRepository(parent)
{
}

void PaymentsOverviewRepositoryImpl::fetchOverview()
{
    if (m_inFlight)
        return;
    m_inFlight = true;

    APIClient::instance().get(
        "/dashboard/payments",
        [this](bool success, const QJsonObject& response)
        {
            m_inFlight = false;
            if (success && response.contains("data")) {
                emit overviewFetched(response["data"].toObject());
            } else {
                emit fetchError(response.value("message").toString());
            }
        }, false
    );
}