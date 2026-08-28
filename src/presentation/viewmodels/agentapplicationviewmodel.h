#ifndef AGENTAPPLICATIONVIEWMODEL_H
#define AGENTAPPLICATIONVIEWMODEL_H

#include <QObject>
#include <QVariantMap>
#include <QHash>
#include "application/controllers/agentcontroller.h"
#include "presentation/models/agentlistmodel.h"

class AgentApplicationViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(AgentListModel* applicationListModel READ applicationListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit AgentApplicationViewModel(QObject *parent = nullptr);

    AgentListModel* applicationListModel() const { return m_applicationListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getApplications();
    Q_INVOKABLE void approve(const QString& applicationId);
    Q_INVOKABLE void reject(const QString& applicationId);
    Q_INVOKABLE QVariantMap findApplication(const QString& applicationId) const;

    Q_INVOKABLE int pendingCount() const;

private:
    void setLoading(bool loading);
    void setApplicationStatus(const QString& applicationId, const QString& status);
    QString statusFor(const QString& applicationId) const;

    bool m_isLoading = false;
    AgentListModel* m_applicationListModel = nullptr;
    AgentController* m_agentController = nullptr;
    QHash<QString, QString> m_statusById;

private slots:
    void onApplicationsLoaded(QList<Agent*>& applications);
    void onApplicationApproved(const QString& applicationId);
    void onApplicationRejected(const QString& applicationId);
    void onAgentError(const QString& error);

signals:
    void isLoadingChanged(bool isLoading);
    void agentError(const QString& error);
    void applicationStatusChanged(const QString& applicationId, const QString& status);
};

#endif // AGENTAPPLICATIONVIEWMODEL_H
