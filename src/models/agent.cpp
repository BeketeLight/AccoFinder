#include "agent.h"

Agent::Agent() {}

QString Agent::getEmployeeId() const
{
    return employeeId;
}

void Agent::setEmployeeId(const QString &newEmployeeId)
{
    employeeId = newEmployeeId;
}

QString Agent::getAssignedArea() const
{
    return assignedArea;
}

void Agent::setAssignedArea(const QString &newAssignedArea)
{
    assignedArea = newAssignedArea;
}

double Agent::getCommissionRate() const
{
    return commissionRate;
}

void Agent::setCommissionRate(double newCommissionRate)
{
    commissionRate = newCommissionRate;
}

bool Agent::getIsActive() const
{
    return isActive;
}

void Agent::setIsActive(bool newIsActive)
{
    isActive = newIsActive;
}
