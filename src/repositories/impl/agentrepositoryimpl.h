#ifndef AGENTREPOSITORYIMPL_H
#define AGENTREPOSITORYIMPL_H

#include <QList>
#include "repositories/interfaces/IAgentRepository.h"

class AgentRepositoryImpl : public IAgentRepository
{
    Q_OBJECT
public:
    explicit AgentRepositoryImpl(QObject *parent = nullptr);

    void getAgents() override;
    void getAgentById(const QString& agentId) override;
    void updateAgent(const QString& agentId, const QString& area, double commissionRate) override;
    void setAgentActive(const QString& agentId, bool active) override;
    void setAllAgentsCommission(double commissionRate) override;
    void getAgentApplications() override;
    void approveApplication(const QString& applicationId) override;
    void rejectApplication(const QString& applicationId, const QString& reason = QString()) override;
    void updateApplicationNotes(const QString& applicationId, const QString& notes) override;

signals:
    void agentsLoaded(QList<Agent*>& agents);
    void agentLoaded(Agent* agent);
    void agentUpdated(Agent* agent);
    void agentError(const QString& error);
    void agentApplicationsLoaded(QList<Agent*>& applications);
    void applicationApproved(const QString& applicationId);
    void applicationRejected(const QString& applicationId);
    void applicationNotesUpdated(const QString& applicationId, const QString& notes);
};

#endif // AGENTREPOSITORYIMPL_H
