#include "agentviewmodel.h"

AgentViewModel::AgentViewModel(QObject *parent)
    : QObject(parent),
      m_agentListModel(new AgentListModel(this)),
      m_agentController(new AgentController(this))
{
    connect(m_agentController, &AgentController::agentsLoaded,
            this, &AgentViewModel::onAgentsLoaded);
    connect(m_agentController, &AgentController::agentUpdated,
            this, &AgentViewModel::onAgentUpdated);
    connect(m_agentController, &AgentController::agentError,
            this, &AgentViewModel::onAgentError);
    connect(m_agentController, &AgentController::myCommissionUpdated,
            this, &AgentViewModel::myCommissionUpdated);
}

void AgentViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void AgentViewModel::getAgents()
{
    setLoading(true);
    m_agentController->getAgents();
}

void AgentViewModel::updateAgent(const QString &agentId, const QString &area, double commissionRate)
{
    setLoading(true);
    m_agentController->updateAgent(agentId, area, commissionRate);
}

void AgentViewModel::setActive(const QString &agentId, bool active)
{
    setLoading(true);
    m_agentController->setAgentActive(agentId, active);
}

void AgentViewModel::setAllAgentsCommission(double commissionRate)
{
    setLoading(true);
    m_agentController->setAllAgentsCommission(commissionRate);
}

void AgentViewModel::getMyCommission()
{
    m_agentController->getMyCommission();
}

void AgentViewModel::addAgent(const QString &firstName, const QString &lastName,
                              const QString &email, const QString &phone,
                              const QString &area, double commissionRate)
{
    Agent* agent = new Agent(QString("AG-%1").arg(100 + m_agentListModel->rowCount() + 1),
                             area, commissionRate, true,
                             firstName, lastName, email, phone,
                             QDateTime::currentDateTime(), this);
    m_agentListModel->addAgent(agent);
}

QVariantMap AgentViewModel::findAgentById(const QString &agentId) const
{
    for (int i = 0; i < m_agentListModel->rowCount(); ++i) {
        const QModelIndex idx = m_agentListModel->index(i, 0);
        if (m_agentListModel->data(idx, AgentListModel::IdRole).toString() == agentId) {
            QVariantMap row;
            row["agentId"] = m_agentListModel->data(idx, AgentListModel::IdRole);
            row["name"] = m_agentListModel->data(idx, AgentListModel::NameRole);
            row["email"] = m_agentListModel->data(idx, AgentListModel::EmailRole);
            row["phone"] = m_agentListModel->data(idx, AgentListModel::PhoneRole);
            row["area"] = m_agentListModel->data(idx, AgentListModel::AreaRole);
            row["commissionRate"] = m_agentListModel->data(idx, AgentListModel::CommissionRateRole);
            row["active"] = m_agentListModel->data(idx, AgentListModel::ActiveRole);
            return row;
        }
    }
    return QVariantMap();
}

int AgentViewModel::activeCount() const
{
    int c = 0;
    for (int i = 0; i < m_agentListModel->rowCount(); ++i) {
        if (m_agentListModel->data(m_agentListModel->index(i, 0), AgentListModel::ActiveRole).toBool())
            ++c;
    }
    return c;
}

double AgentViewModel::averageCommission() const
{
    int count = m_agentListModel->rowCount();
    if (count <= 0)
        return 0.0;
    double total = 0.0;
    for (int i = 0; i < count; ++i) {
        total += m_agentListModel->data(m_agentListModel->index(i, 0), AgentListModel::CommissionRateRole).toDouble();
    }
    return total / count;
}

void AgentViewModel::onAgentsLoaded(QList<Agent *> &agents)
{
    setLoading(false);
    m_agentListModel->setAgents(agents);
}

void AgentViewModel::onAgentUpdated(Agent *agent)
{
    setLoading(false);
    m_agentListModel->updateAgentById(agent->getEmployeeId(), agent);
    emit agentUpdatedSignal(agent->getEmployeeId());
}

void AgentViewModel::onAgentError(const QString &error)
{
    setLoading(false);
    emit agentError(error);
}
