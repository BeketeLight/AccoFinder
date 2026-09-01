#include "dashboardcontroller.h"

DashboardController::DashboardController(QObject *parent)
    : QObject(parent),
      m_repository(new DashboardRepositoryImpl(this))
{
    connect(m_repository, &DashboardRepositoryImpl::statsFetched,
            this, [this](const QJsonObject& stats) {
        applyStats(stats);
        setLoading(false);
        emit statsUpdated();
    });

    connect(m_repository, &DashboardRepositoryImpl::fetchError,
            this, [this](const QString& error) {
        setLoading(false);
        emit dashboardError(error);
    });
}

void DashboardController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void DashboardController::applyStats(const QJsonObject& stats)
{
    m_totalUsers = stats.value("totalUsers").toInt();
    m_totalAgents = stats.value("totalAgents").toInt();
    m_totalProperties = stats.value("totalProperties").toInt();
    m_pendingVerifications = stats.value("pendingVerifications").toInt();
    m_totalBookings = stats.value("totalBookings").toInt();
    m_totalBookingValue = stats.value("totalBookingValue").toDouble();
    m_platformCommission = stats.value("platformCommission").toDouble();
    m_openDisputes = stats.value("openDisputes").toInt();
}

void DashboardController::refreshStats()
{
    setLoading(true);
    m_repository->fetchStats();
}