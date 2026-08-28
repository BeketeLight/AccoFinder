#ifndef AGENTLISTMODEL_H
#define AGENTLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QList>
#include <QHash>
#include <QByteArray>
#include <QVariantMap>
#include "models/agent.h"
class AgentListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        EmailRole,
        PhoneRole,
        AreaRole,
        CommissionRateRole,
        ActiveRole,
        StatusRole,
        AppliedDateRole
    };

    explicit AgentListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const { return m_agents.size(); }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setAgents(QList<Agent*> agents);
    void addAgent(Agent* agent);
    void updateAgentById(const QString& agentId, Agent* agent);
    int indexOfId(const QString& agentId) const;
    void clear();

    void setStatusById(const QString& agentId, const QString& status);
    QString statusById(const QString& agentId) const;

    Q_INVOKABLE int size() const { return m_agents.size(); }
    Q_INVOKABLE QVariantMap at(int index) const;
    Q_INVOKABLE QVariantMap byId(const QString& agentId) const;

signals:
    void countChanged(int newCount);

private:
    QVector<Agent*> m_agents;
    QHash<QString, QString> m_statusOverride;
};

#endif // AGENTLISTMODEL_H
