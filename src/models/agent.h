#ifndef AGENT_H
#define AGENT_H

#include "user.h"

class Agent : public User
{
public:
    Agent();
    QString getEmployeeId() const;
    void setEmployeeId(const QString &newEmployeeId);

    QString getAssignedArea() const;
    void setAssignedArea(const QString &newAssignedArea);

    double getCommissionRate() const;
    void setCommissionRate(double newCommissionRate);

    bool getIsActive() const;
    void setIsActive(bool newIsActive);

private:
    QString employeeId;
    QString assignedArea;
    double commissionRate;
    bool isActive;
signals:
};

#endif // AGENT_H
