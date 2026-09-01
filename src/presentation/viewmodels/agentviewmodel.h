#ifndef AGENTVIEWMODEL_H
#define AGENTVIEWMODEL_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include "application/controllers/agentcontroller.h"
#include "presentation/models/agentlistmodel.h"

class AgentViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(AgentListModel* agentListModel READ agentListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit AgentViewModel(QObject *parent = nullptr);

    AgentListModel* agentListModel() const { return m_agentListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getAgents();
    Q_INVOKABLE void updateAgent(const QString& agentId, const QString& area, double commissionRate);
    Q_INVOKABLE void setActive(const QString& agentId, bool active);
    Q_INVOKABLE void setAllAgentsCommission(double commissionRate);
    Q_INVOKABLE void getMyCommission();
    Q_INVOKABLE void addAgent(const QString& firstName,
                              const QString& lastName,
                              const QString& email,
                              const QString& phone,
                              const QString& area,
                              double commissionRate);
    Q_INVOKABLE QVariantMap findAgentById(const QString& agentId) const;

    Q_INVOKABLE int activeCount() const;
    Q_INVOKABLE double averageCommission() const;

private:
    bool m_isLoading = false;
    AgentListModel* m_agentListModel = nullptr;
    AgentController* m_agentController = nullptr;

    void setLoading(bool loading);

private slots:
    void onAgentsLoaded(QList<Agent*>& agents);
    void onAgentUpdated(Agent* agent);
    void onAgentError(const QString& error);

signals:
    void isLoadingChanged(bool isLoading);
    void agentError(const QString& error);
    void agentUpdatedSignal(const QString& agentId);
    void myCommissionUpdated(double commissionRate);
};

#endif // AGENTVIEWMODEL_H
