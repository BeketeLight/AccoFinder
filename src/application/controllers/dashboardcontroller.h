#ifndef DASHBOARDCONTROLLER_H
#define DASHBOARDCONTROLLER_H

#include <QObject>
#include <QJsonObject>
#include "repositories/impl/dashboardrepositoryimpl.h"

class DashboardController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(int totalUsers READ totalUsers NOTIFY statsUpdated)
    Q_PROPERTY(int totalProperties READ totalProperties NOTIFY statsUpdated)
    Q_PROPERTY(int totalAgents READ totalAgents NOTIFY statsUpdated)
    Q_PROPERTY(int pendingVerifications READ pendingVerifications NOTIFY statsUpdated)
    Q_PROPERTY(int totalBookings READ totalBookings NOTIFY statsUpdated)
    Q_PROPERTY(double totalBookingValue READ totalBookingValue NOTIFY statsUpdated)
    Q_PROPERTY(double platformCommission READ platformCommission NOTIFY statsUpdated)
    Q_PROPERTY(int openDisputes READ openDisputes NOTIFY statsUpdated)
public:
    explicit DashboardController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }
    int totalUsers() const { return m_totalUsers; }
    int totalProperties() const { return m_totalProperties; }
    int totalAgents() const { return m_totalAgents; }
    int pendingVerifications() const { return m_pendingVerifications; }
    int totalBookings() const { return m_totalBookings; }
    double totalBookingValue() const { return m_totalBookingValue; }
    double platformCommission() const { return m_platformCommission; }
    int openDisputes() const { return m_openDisputes; }

    Q_INVOKABLE void refreshStats();

signals:
    void statsUpdated();
    void dashboardError(const QString& error);
    void isLoadingChanged(bool isLoading);

private:
    DashboardRepositoryImpl* m_repository = nullptr;
    bool m_isLoading = false;
    int m_totalUsers = 0;
    int m_totalProperties = 0;
    int m_totalAgents = 0;
    int m_pendingVerifications = 0;
    int m_totalBookings = 0;
    double m_totalBookingValue = 0.0;
    double m_platformCommission = 0.0;
    int m_openDisputes = 0;

    void setLoading(bool loading);
    void applyStats(const QJsonObject& stats);
};

#endif // DASHBOARDCONTROLLER_H