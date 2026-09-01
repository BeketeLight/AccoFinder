#ifndef IAGENTREPOSITORY_H
#define IAGENTREPOSITORY_H

#include <QObject>
#include "models/agent.h"

class IAgentRepository : public QObject
{
    Q_OBJECT
public:
    explicit IAgentRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    virtual void getAgents() = 0;
    virtual void getAgentById(const QString& agentId) = 0;
    virtual void updateAgent(const QString& agentId, const QString& area, double commissionRate) = 0;
    virtual void setAgentActive(const QString& agentId, bool active) = 0;
    virtual void setAllAgentsCommission(double commissionRate) = 0;
    virtual void getMyCommission() = 0;
    virtual void getAgentApplications() = 0;
    virtual void approveApplication(const QString& applicationId) = 0;
    virtual void rejectApplication(const QString& applicationId, const QString& reason = QString()) = 0;
    virtual void updateApplicationNotes(const QString& applicationId, const QString& notes) = 0;
    virtual ~IAgentRepository() {}
};

#endif // IAGENTREPOSITORY_H
