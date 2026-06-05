#include "dispute.h"

Dispute::Dispute(QObject *parent)
    :QObject(parent)
{}

QString Dispute::getId() const
{
    return id;
}

void Dispute::setId(const QString &newId)
{
    id = newId;
}

QString Dispute::getBookingId() const
{
    return bookingId;
}

void Dispute::setBookingId(const QString &newBookingId)
{
    bookingId = newBookingId;
}

QString Dispute::getIssue() const
{
    return issue;
}

void Dispute::setIssue(const QString &newIssue)
{
    issue = newIssue;
}

DisputeStatus Dispute::getStatus() const
{
    return status;
}

void Dispute::setStatus(DisputeStatus newStatus)
{
    status = newStatus;
}
