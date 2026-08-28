#include "agentrepositoryimpl.h"
#include "services/apiclient.h"
#include <QJsonObject>
#include <QJsonArray>

AgentRepositoryImpl::AgentRepositoryImpl(QObject *parent)
    : IAgentRepository(parent)
{
}

void AgentRepositoryImpl::getAgents()
{
    APIClient::instance().get(
        "/agents/",
        [this](bool success, const QJsonObject& response)
        {
            QList<Agent*> agents;
            if (success && response.contains("data")) {
                QJsonArray dataArray = response["data"].toArray();
                for (const QJsonValue& value : std::as_const(dataArray)) {
                    QJsonObject obj = value.toObject();
                    Agent* agent = new Agent(
                        obj["employeeId"].toString(),
                        obj["assignedArea"].toString(),
                        obj["commissionRate"].toDouble(),
                        obj["isActive"].toBool(),
                        obj["firstName"].toString(),
                        obj["lastName"].toString(),
                        obj["email"].toString(),
                        obj["phone"].toString(),
                        QDateTime::fromString(obj["createdAt"].toString(), Qt::ISODate),
                        this
                    );
                    agents.append(agent);
                }
                emit agentsLoaded(agents);
            } else {
                emit agentError(response.value("message").toString());
            }
        }, false
    );
}

void AgentRepositoryImpl::getAgentById(const QString &agentId)
{
    APIClient::instance().get(
        "/agents/" + agentId,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                QJsonObject obj = response["data"].toObject();
                Agent* agent = new Agent(
                    obj["employeeId"].toString(),
                    obj["assignedArea"].toString(),
                    obj["commissionRate"].toDouble(),
                    obj["isActive"].toBool(),
                    obj["firstName"].toString(),
                    obj["lastName"].toString(),
                    obj["email"].toString(),
                    obj["phone"].toString(),
                    QDateTime::fromString(obj["createdAt"].toString(), Qt::ISODate),
                    this
                );
                emit agentLoaded(agent);
            } else {
                emit agentError(response.value("message").toString());
            }
        }, false
    );
}

void AgentRepositoryImpl::updateAgent(const QString &agentId, const QString &area, double commissionRate)
{
    QJsonObject payload;
    if (!area.isEmpty()) payload["assignedArea"] = area;
    if (commissionRate > 0) payload["commissionRate"] = commissionRate;

    APIClient::instance().patch(
        "/agents/" + agentId,
        payload,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                QJsonObject obj = response["data"].toObject();
                Agent* agent = new Agent(
                    obj["employeeId"].toString(),
                    obj["assignedArea"].toString(),
                    obj["commissionRate"].toDouble(),
                    obj["isActive"].toBool(),
                    obj["firstName"].toString(),
                    obj["lastName"].toString(),
                    obj["email"].toString(),
                    obj["phone"].toString(),
                    QDateTime::fromString(obj["createdAt"].toString(), Qt::ISODate),
                    this
                );
                emit agentUpdated(agent);
            } else {
                emit agentError(response.value("message").toString());
            }
        }, false
    );
}

void AgentRepositoryImpl::setAgentActive(const QString &agentId, bool active)
{
    QJsonObject payload;
    payload["isActive"] = active;

    APIClient::instance().patch(
        "/agents/" + agentId + "/status",
        payload,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                QJsonObject obj = response["data"].toObject();
                Agent* agent = new Agent(
                    obj["employeeId"].toString(),
                    obj["assignedArea"].toString(),
                    obj["commissionRate"].toDouble(),
                    obj["isActive"].toBool(),
                    obj["firstName"].toString(),
                    obj["lastName"].toString(),
                    obj["email"].toString(),
                    obj["phone"].toString(),
                    QDateTime::fromString(obj["createdAt"].toString(), Qt::ISODate),
                    this
                );
                emit agentUpdated(agent);
            } else {
                emit agentError(response.value("message").toString());
            }
        }, false
    );
}

void AgentRepositoryImpl::getAgentApplications()
{
    APIClient::instance().get(
        "/agent-applications/",
        [this](bool success, const QJsonObject& response)
        {
            QList<Agent*> applications;
            if (success && response.contains("data")) {
                QJsonArray dataArray = response["data"].toArray();
                for (const QJsonValue& value : std::as_const(dataArray)) {
                    QJsonObject obj = value.toObject();
                    Agent* agent = new Agent(
                        obj["applicationId"].toString(),
                        obj["preferredArea"].toString(),
                        0, false,
                        obj["firstName"].toString(),
                        obj["lastName"].toString(),
                        obj["email"].toString(),
                        obj["phone"].toString(),
                        QDateTime::fromString(obj["appliedDate"].toString(), Qt::ISODate),
                        this
                    );
                    applications.append(agent);
                }
                emit agentApplicationsLoaded(applications);
            } else {
                emit agentError(response.value("message").toString());
            }
        }, false
    );
}

void AgentRepositoryImpl::approveApplication(const QString &applicationId)
{
    QJsonObject payload;
    payload["status"] = "Approved";

    APIClient::instance().patch(
        "/agent-applications/" + applicationId + "/approve",
        payload,
        [this, applicationId](bool success, const QJsonObject& response)
        {
            if (success) {
                emit applicationApproved(applicationId);
            } else {
                emit agentError(response.value("message").toString());
            }
        }, false
    );
}

void AgentRepositoryImpl::rejectApplication(const QString &applicationId)
{
    QJsonObject payload;
    payload["status"] = "Rejected";

    APIClient::instance().patch(
        "/agent-applications/" + applicationId + "/reject",
        payload,
        [this, applicationId](bool success, const QJsonObject& response)
        {
            if (success) {
                emit applicationRejected(applicationId);
            } else {
                emit agentError(response.value("message").toString());
            }
        }, false
    );
}
