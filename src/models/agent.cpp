#include "agent.h"

Agent::Agent(const QString& employeeId,
             const QString& assignedArea,
             const double& commissionRate,
             const bool& isActive,
             const QString& name,
             const QString& email,
             const QString& phone,
             const QDateTime& createdAt,
             QObject* parent)
    :User(employeeId,name,email,phone,createdAt)
    ,m_employeeId(employeeId)
    ,m_assignedArea(assignedArea)
    ,m_commissionRate(commissionRate)
    ,m_isActive(isActive)
{
    emit agentProfileCreated();
}

QString Agent::getEmployeeId() const
{
    return m_employeeId;
}


QString Agent::getAssignedArea() const
{
    return m_assignedArea;
}

void Agent::setAssignedArea(const QString &assignedArea)
{
    m_assignedArea = assignedArea;
    emit assignedAreaChanged();
}

double Agent::getCommissionRate() const
{
    return m_commissionRate;
}

void Agent::setCommissionRate(double commissionRate)
{
    m_commissionRate = commissionRate;
    emit commissionRateChanged();
}

bool Agent::getIsActive() const
{
    return m_isActive;
}

void Agent::setIsActive(bool isActive)
{
    m_isActive = isActive;
    emit isActiveChanged();
}
