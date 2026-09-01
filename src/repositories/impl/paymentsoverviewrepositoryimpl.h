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
};

#endif // PAYMENTSOVERVIEWREPOSITORYIMPL_H