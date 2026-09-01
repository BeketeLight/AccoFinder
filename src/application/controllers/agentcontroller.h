#ifndef AGENTCONTROLLER_H
#define AGENTCONTROLLER_H

#include <QObject>
#include <QList>
#include "models/agent.h"
#include "repositories/impl/agentrepositoryimpl.h"

class AgentController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit AgentController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getAgents();
    Q_INVOKABLE void getAgentById(const QString& agentId);
    Q_INVOKABLE void updateAgent(const QString& agentId, const QString& area, double commissionRate);
    Q_INVOKABLE void setAgentActive(const QString& agentId, bool active);
    Q_INVOKABLE void setAllAgentsCommission(double commissionRate);
    Q_INVOKABLE void getAgentApplications();
    Q_INVOKABLE void approveApplication(const QString& applicationId);
    Q_INVOKABLE void rejectApplication(const QString& applicationId, const QString& reason = QString());
    Q_INVOKABLE void updateApplicationNotes(const QString& applicationId, const QString& notes);

signals:
    void agentsLoaded(QList<Agent*>& agents);
    void agentLoaded(Agent* agent);
    void agentUpdated(Agent* agent);
    void agentError(const QString& error);
    void agentApplicationsLoaded(QList<Agent*>& applications);
    void applicationApproved(const QString& applicationId);
    void applicationRejected(const QString& applicationId);
    void applicationNotesUpdated(const QString& applicationId, const QString& notes);
    void isLoadingChanged(bool isLoading);

private:
    AgentRepositoryImpl* m_repository = nullptr;
    bool m_isLoading = false;

    void setLoading(bool loading);
};

#endif // AGENTCONTROLLER_H
