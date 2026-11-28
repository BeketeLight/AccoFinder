#include "disputerepositoryimpl.h"

#include "services/apiclient.h"

#include <QDebug>
#include <QJsonObject>

namespace {
QString errorFrom(const QJsonObject &response, const QString &fallback)
{
    const QString message = response.value(QStringLiteral("message")).toString().trimmed();
    if (!message.isEmpty())
        return message;
    const QString error = response.value(QStringLiteral("error")).toString().trimmed();
    return error.isEmpty() ? fallback : error;
}
} // namespace

DisputeRepositoryImpl::DisputeRepositoryImpl(QObject *parent)
    : IDisputeRepository(parent)
{
}

void DisputeRepositoryImpl::raiseDispute(const QString &bookingId, const QString &issue)
{
    QJsonObject payload;
    payload[QStringLiteral("bookingId")] = bookingId;
    payload[QStringLiteral("issue")] = issue;

    APIClient::instance().post(
        QStringLiteral("/disputes/"),
        payload,
        [this](bool success, const QJsonObject &response) {
            if (!success) {
                emit disputeError(errorFrom(response, QStringLiteral("Could not raise dispute.")),
                                  QStringLiteral("raise"));
                return;
            }

            const DisputeDto dispute = DisputeDto::fromApiResponse(response);
            if (dispute.m_id.isEmpty()) {
                emit disputeError(QStringLiteral("Dispute response was empty."),
                                  QStringLiteral("raise"));
                return;
            }
            emit disputeRaised(dispute);
        },
        false);
}

void DisputeRepositoryImpl::resolveDispute(const QString &disputeId, const QString &status)
{
    QJsonObject payload;
    payload[QStringLiteral("status")] = status.isEmpty()
                                           ? QStringLiteral("Resolved")
                                           : status;

    APIClient::instance().patch(
        QStringLiteral("/disputes/") + disputeId + QStringLiteral("/resolve"),
        payload,
        [this](bool success, const QJsonObject &response) {
            if (!success) {
                emit disputeError(errorFrom(response, QStringLiteral("Could not update dispute.")),
                                  QStringLiteral("resolve"));
                return;
            }

            const DisputeDto dispute = DisputeDto::fromApiResponse(response);
            if (dispute.m_id.isEmpty()) {
                emit disputeError(QStringLiteral("Dispute response was empty."),
                                  QStringLiteral("resolve"));
                return;
            }
            emit disputeResolved(dispute);
        },
        false);
}

void DisputeRepositoryImpl::getDisputes()
{
    // Rapid footer taps used to fire several loads at once. Coalesce them into
    // one in-flight request; the generation guards against a late reply ever
    // being applied after the list has been invalidated by a newer request.
    if (m_getInFlight)
        return;

    const quint64 generation = ++m_getGeneration;
    m_getInFlight = true;

    APIClient::instance().get(
        QStringLiteral("/disputes/"),
        [this, generation](bool success, const QJsonObject &response) {
            if (generation != m_getGeneration) {
                qWarning() << "Ignoring stale disputes response, generation"
                           << generation << "current" << m_getGeneration;
                return;
            }

            m_getInFlight = false;

            if (!success) {
                emit disputeError(errorFrom(response, QStringLiteral("Could not load disputes.")),
                                  QStringLiteral("list"));
                return;
            }

            const QList<DisputeDto> disputes = DisputeDto::listFromApiResponse(response);
            emit disputesLoaded(disputes);
        },
        false);
}
