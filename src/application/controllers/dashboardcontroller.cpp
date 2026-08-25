#include "dashboardcontroller.h"

DashboardController::DashboardController(QObject *parent)
    : QObject(parent),
      m_userRepo(new AdminUserRepositoryImpl(this)),
      m_agentRepo(new AgentRepositoryImpl(this)),
      m_propertyRepo(new PropertyRepositoryImpl(this))
{
    connect(m_userRepo, &AdminUserRepositoryImpl::usersLoaded,
            this, [this](QList<User*>& users) {
        m_totalUsers = users.size();
        qDeleteAll(users);
        tryEmitStats();
    });

    connect(m_agentRepo, &AgentRepositoryImpl::agentsLoaded,
            this, [this](QList<Agent*>& agents) {
        m_totalAgents = agents.size();
        qDeleteAll(agents);
        tryEmitStats();
    });

    connect(m_propertyRepo, &PropertyRepositoryImpl::propertiesLoaded,
            this, [this](QList<Property*>& properties) {
        m_totalProperties = properties.size();
        qDeleteAll(properties);
        tryEmitStats();
    });
}

void DashboardController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void DashboardController::tryEmitStats()
{
    m_pendingCount--;
    if (m_pendingCount <= 0) {
        setLoading(false);
        emit statsUpdated();
    }
}

void DashboardController::refreshStats()
{
    setLoading(true);
    m_pendingCount = 3;

    m_userRepo->getUsers();
    m_agentRepo->getAgents();
    m_propertyRepo->getProperties();
}
