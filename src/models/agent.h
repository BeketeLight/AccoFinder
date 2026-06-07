#ifndef AGENT_H
#define AGENT_H

#include <QDateTime>
#include "user.h"

class Agent : public User
{
    Q_OBJECT
public:
    Agent(const QString& employeeId,
          const QString& assignedArea,
          const double& commissionRate,
          const bool& isActive,
          const QString& name,
          const QString& email,
          const QString& phone,
          const QDateTime& createdAt,
          QObject* parent = nullptr);

    QString getEmployeeId() const;

    QString getAssignedArea() const;
    void setAssignedArea(const QString &assignedArea);

    double getCommissionRate() const;
    void setCommissionRate(double commissionRate);

    bool getIsActive() const;
    void setIsActive(bool isActive);

private:
    QString m_employeeId;
    QString m_assignedArea;
    double m_commissionRate;
    bool m_isActive;
signals:
    void agentProfileCreated();
    void commissionRateChanged();
    void assignedAreaChanged();
    void isActiveChanged();
};

#endif // AGENT_H
