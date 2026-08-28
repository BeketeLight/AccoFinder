#include "agentapplicationviewmodel.h"

AgentApplicationViewModel::AgentApplicationViewModel(QObject *parent)
    : QObject(parent),
      m_applicationListModel(new AgentListModel(this)),
      m_agentController(new AgentController(this))
{
    connect(m_agentController, &AgentController::agentApplicationsLoaded,
            this, &AgentApplicationViewModel::onApplicationsLoaded);
    connect(m_agentController, &AgentController::applicationApproved,
            this, &AgentApplicationViewModel::onApplicationApproved);
    connect(m_agentController, &AgentController::applicationRejected,
            this, &AgentApplicationViewModel::onApplicationRejected);
    connect(m_agentController, &AgentController::agentError,
            this, &AgentApplicationViewModel::onAgentError);
}

void AgentApplicationViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void AgentApplicationViewModel::getApplications()
{
    setLoading(true);
    m_agentController->getAgentApplications();
}

void AgentApplicationViewModel::approve(const QString &applicationId)
{
    setLoading(true);
    m_agentController->approveApplication(applicationId);
}

void AgentApplicationViewModel::reject(const QString &applicationId)
{
    setLoading(true);
    m_agentController->rejectApplication(applicationId);
}

QVariantMap AgentApplicationViewModel::findApplication(const QString &applicationId) const
{
    for (int i = 0; i < m_applicationListModel->rowCount(); ++i) {
        const QModelIndex idx = m_applicationListModel->index(i, 0);
        if (m_applicationListModel->data(idx, AgentListModel::IdRole).toString() == applicationId) {
            QVariantMap row;
            row["applicationId"] = m_applicationListModel->data(idx, AgentListModel::IdRole);
            row["name"] = m_applicationListModel->data(idx, AgentListModel::NameRole);
            row["email"] = m_applicationListModel->data(idx, AgentListModel::EmailRole);
            row["phone"] = m_applicationListModel->data(idx, AgentListModel::PhoneRole);
            row["area"] = m_applicationListModel->data(idx, AgentListModel::AreaRole);
            row["status"] = m_applicationListModel->data(idx, AgentListModel::StatusRole);
            row["appliedDate"] = m_applicationListModel->data(idx, AgentListModel::AppliedDateRole);
            return row;
        }
    }
    return QVariantMap();
}

int AgentApplicationViewModel::pendingCount() const
{
    int c = 0;
    for (int i = 0; i < m_applicationListModel->rowCount(); ++i) {
        if (m_applicationListModel->data(m_applicationListModel->index(i, 0), AgentListModel::StatusRole).toString() == "Pending")
            ++c;
    }
    return c;
}

void AgentApplicationViewModel::setApplicationStatus(const QString &applicationId, const QString &status)
{
    m_applicationListModel->setStatusById(applicationId, status);
    emit applicationStatusChanged(applicationId, status);
}

QString AgentApplicationViewModel::statusFor(const QString &applicationId) const
{
    return m_applicationListModel->statusById(applicationId);
}

void AgentApplicationViewModel::onApplicationsLoaded(QList<Agent *> &applications)
{
    setLoading(false);
    m_applicationListModel->setAgents(applications);
    // Default all to Pending unless an override already exists
    for (int i = 0; i < m_applicationListModel->rowCount(); ++i) {
        const QModelIndex idx = m_applicationListModel->index(i, 0);
        const QString id = m_applicationListModel->data(idx, AgentListModel::IdRole).toString();
        if (statusFor(id).isEmpty())
            m_applicationListModel->setStatusById(id, "Pending");
    }
}

void AgentApplicationViewModel::onApplicationApproved(const QString &applicationId)
{
    setLoading(false);
    setApplicationStatus(applicationId, "Approved");
}

void AgentApplicationViewModel::onApplicationRejected(const QString &applicationId)
{
    setLoading(false);
    setApplicationStatus(applicationId, "Rejected");
}

void AgentApplicationViewModel::onAgentError(const QString &error)
{
    setLoading(false);
    emit agentError(error);
}
