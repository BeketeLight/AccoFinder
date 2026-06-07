#include "dispute.h"

Dispute::Dispute(const QString &id,
                 const QString &bookingId,
                 const QString &issue,
                 const DisputeStatus &status,
                 QObject *parent)
    :m_id(id)
    ,m_bookingId(bookingId)
    ,m_issue(issue)
    ,m_status(status)
    ,QObject(parent)
{
    emit disputeRaised();

}

QString Dispute::getId() const
{
    return m_id;
}

QString Dispute::getBookingId() const
{
    return m_bookingId;
}


QString Dispute::getIssue() const
{
    return m_issue;
}

void Dispute::setIssue(const QString &issue)
{
    m_issue = issue;
}

DisputeStatus Dispute::getStatus() const
{
    return m_status;
}

void Dispute::setStatus(DisputeStatus status)
{
    m_status = status;
    if (getStatus() == DisputeStatus::Resolved)
    {
        emit disputeResolved();
    }
}
