#ifndef IPAYMENTSOVERVIEWREPOSITORY_H
#define IPAYMENTSOVERVIEWREPOSITORY_H

#include <QObject>
#include <QJsonObject>

class IPaymentsOverviewRepository : public QObject
{
    Q_OBJECT
public:
    explicit IPaymentsOverviewRepository(QObject *parent = nullptr)
        : QObject(parent) {}

    virtual void fetchOverview() = 0;

    virtual ~IPaymentsOverviewRepository() {}
};

#endif // IPAYMENTSOVERVIEWREPOSITORY_H