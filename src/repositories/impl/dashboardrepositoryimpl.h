#ifndef DASHBOARDREPOSITORYIMPL_H
#define DASHBOARDREPOSITORYIMPL_H

#include <QList>
#include <QJsonObject>
#include "repositories/interfaces/IDashboardRepository.h"

class DashboardRepositoryImpl : public IDashboardRepository
{
    Q_OBJECT
public:
    explicit DashboardRepositoryImpl(QObject *parent = nullptr);

    void fetchStats() override;

signals:
    void statsFetched(const QJsonObject& stats);
    void fetchError(const QString& error);
};

#endif // DASHBOARDREPOSITORYIMPL_H