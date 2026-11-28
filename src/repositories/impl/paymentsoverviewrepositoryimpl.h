#ifndef PAYMENTSOVERVIEWREPOSITORYIMPL_H
#define PAYMENTSOVERVIEWREPOSITORYIMPL_H

#include <QJsonObject>
#include "repositories/interfaces/IPaymentsOverviewRepository.h"

class PaymentsOverviewRepositoryImpl : public IPaymentsOverviewRepository
{
    Q_OBJECT
public:
    explicit PaymentsOverviewRepositoryImpl(QObject *parent = nullptr);

    void fetchOverview() override;

signals:
    void overviewFetched(const QJsonObject& data);
    void fetchError(const QString& error);

private:
    // The dashboard card and the oversight screen both refresh this endpoint
    // when the latter is opened. Share one request so the second caller waits
    // on the same signal instead of doubling backend work.
    bool m_inFlight = false;
};

#endif // PAYMENTSOVERVIEWREPOSITORYIMPL_H