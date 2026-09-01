#include "agentcontroller.h"

AgentController::AgentController(QObject *parent)
    : QObject(parent),
      m_repository(new AgentRepositoryImpl(this))
{
    connect(m_repository, &AgentRepositoryImpl::agentsLoaded,
            this, &AgentController::agentsLoaded);
    connect(m_repository, &AgentRepositoryImpl::agentLoaded,
            this, &AgentController::agentLoaded);
    connect(m_repository, &AgentRepositoryImpl::agentUpdated,
            this, &AgentController::agentUpdated);
    connect(m_repository, &AgentRepositoryImpl::agentError,
            this, &AgentController::agentError);
    connect(m_repository, &AgentRepositoryImpl::agentApplicationsLoaded,
            this, &AgentController::agentApplicationsLoaded);
    connect(m_repository, &AgentRepositoryImpl::applicationApproved,
            this, &AgentController::applicationApproved);
    connect(m_repository, &AgentRepositoryImpl::applicationRejected,
            this, &AgentController::applicationRejected);
    connect(m_repository, &AgentRepositoryImpl::applicationNotesUpdated,
            this, &AgentController::applicationNotesUpdated);
}

void AgentController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void AgentController::getAgents()
{
    setLoading(true);
    m_repository->getAgents();
}

void AgentController::getAgentById(const QString &agentId)
{
    if (agentId.isEmpty()) {
        emit agentError("agentId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->getAgentById(agentId);
}

void AgentController::updateAgent(const QString &agentId, const QString &area, double commissionRate)
{
    if (agentId.isEmpty()) {
        emit agentError("agentId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->updateAgent(agentId, area, commissionRate);
}

void AgentController::setAgentActive(const QString &agentId, bool active)
{
    if (agentId.isEmpty()) {
        emit agentError("agentId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->setAgentActive(agentId, active);
}

void AgentController::setAllAgentsCommission(double commissionRate)
{
    setLoading(true);
    m_repository->setAllAgentsCommission(commissionRate);
}

void AgentController::getAgentApplications()
{
    setLoading(true);
    m_repository->getAgentApplications();
}

void AgentController::approveApplication(const QString &applicationId)
{
    if (applicationId.isEmpty()) {
        emit agentError("applicationId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->approveApplication(applicationId);
}

void AgentController::rejectApplication(const QString &applicationId)
{
    if (applicationId.isEmpty()) {
        emit agentError("applicationId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->rejectApplication(applicationId);
}

void AgentController::updateApplicationNotes(const QString &applicationId, const QString &notes)
{
    if (applicationId.isEmpty()) {
        emit agentError("applicationId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->updateApplicationNotes(applicationId, notes);
}
