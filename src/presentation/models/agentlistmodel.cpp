#include "agentlistmodel.h"

AgentListModel::AgentListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int AgentListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_agents.size();
}

QVariant AgentListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_agents.size())
        return QVariant();

    Agent* agent = m_agents.at(index.row());
    switch (role)
    {
        case IdRole:
            return agent->getEmployeeId();
        case NameRole:
            return agent->getFullName();
        case EmailRole:
            return agent->getEmail();
        case PhoneRole:
            return agent->getPhone();
        case AreaRole:
            return agent->getAssignedArea();
        case CommissionRateRole:
            return agent->getCommissionRate();
        case ActiveRole:
            return agent->getIsActive();
        case StatusRole:
            return statusById(agent->getEmployeeId()).isEmpty()
                    ? (agent->getIsActive() ? "Active" : "Suspended")
                    : statusById(agent->getEmployeeId());
        case AppliedDateRole:
            return agent->getCreatedAt().isValid()
                    ? agent->getCreatedAt().toString("dd MMM yyyy")
                    : QString();
    }
    return QVariant();
}

QHash<int, QByteArray> AgentListModel::roleNames() const
{
    static QHash<int,QByteArray> mapping{
        {IdRole, "agentId"},
        {NameRole, "name"},
        {EmailRole, "email"},
        {PhoneRole, "phone"},
        {AreaRole, "area"},
        {CommissionRateRole, "commissionRate"},
        {ActiveRole, "active"},
        {StatusRole, "status"},
        {AppliedDateRole, "appliedDate"}
    };
    return mapping;
}

void AgentListModel::setAgents(QList<Agent *> agents)
{
    beginResetModel();
    qDeleteAll(m_agents);
    m_agents.clear();
    for (Agent* a : agents)
        m_agents.append(a);
    endResetModel();
    emit countChanged(m_agents.size());
}

void AgentListModel::addAgent(Agent *agent)
{
    beginInsertRows(QModelIndex(), m_agents.size(), m_agents.size());
    m_agents.append(agent);
    endInsertRows();
    emit countChanged(m_agents.size());
}

void AgentListModel::updateAgentById(const QString &agentId, Agent *agent)
{
    int idx = indexOfId(agentId);
    if (idx < 0) {
        addAgent(agent);
        return;
    }
    beginResetModel();
    delete m_agents.at(idx);
    m_agents[idx] = agent;
    endResetModel();
}

int AgentListModel::indexOfId(const QString &agentId) const
{
    for (int i = 0; i < m_agents.size(); ++i) {
        if (m_agents.at(i)->getEmployeeId() == agentId)
            return i;
    }
    return -1;
}

void AgentListModel::clear()
{
    beginResetModel();
    qDeleteAll(m_agents);
    m_agents.clear();
    endResetModel();
    emit countChanged(0);
}

void AgentListModel::setStatusById(const QString &agentId, const QString &status)
{
    if (statusById(agentId) == status)
        return;
    if (status.isEmpty())
        m_statusOverride.remove(agentId);
    else
        m_statusOverride[agentId] = status;

    int idx = indexOfId(agentId);
    if (idx >= 0)
        emit dataChanged(index(idx, 0), index(idx, 0), {StatusRole});
}

QString AgentListModel::statusById(const QString &agentId) const
{
    return m_statusOverride.value(agentId);
}

QVariantMap AgentListModel::at(int index) const
{
    if (index < 0 || index >= m_agents.size())
        return QVariantMap();
    const QModelIndex idx = this->index(index, 0);
    QVariantMap row;
    row["agentId"] = data(idx, IdRole);
    row["name"] = data(idx, NameRole);
    row["email"] = data(idx, EmailRole);
    row["phone"] = data(idx, PhoneRole);
    row["area"] = data(idx, AreaRole);
    row["commissionRate"] = data(idx, CommissionRateRole);
    row["active"] = data(idx, ActiveRole);
    row["status"] = data(idx, StatusRole);
    row["appliedDate"] = data(idx, AppliedDateRole);
    return row;
}

QVariantMap AgentListModel::byId(const QString &agentId) const
{
    return at(indexOfId(agentId));
}
