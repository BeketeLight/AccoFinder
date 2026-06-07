#include "verification.h"

Verification::Verification(const QString &id,
                           const QString agentId,
                           const QString propertyId,
                           const QString notes,
                           const QDateTime verifiedAt,
                           const VerificationStatus &status,
                           QObject *parent)
    :m_id(id)
    ,m_agentId(agentId)
    ,m_propertyId(propertyId)
    ,m_notes(notes)
    ,m_verifiedAt(verifiedAt)
    ,m_status(status)
{

}

QString Verification::getId() const
{
    return m_id;
}


QString Verification::getPropertyId() const
{
    return m_propertyId;
}


VerificationStatus Verification::getStatus() const
{
    return m_status;
}

void Verification::setStatus(VerificationStatus& status)
{
    m_status = status;
    if (getStatus() == VerificationStatus::Approved)
        emit verificationApproved();
    else if (getStatus() == VerificationStatus::Rejected)
        emit verificationRejected();

}

QString Verification::agentId() const
{
    return m_agentId;
}

QString Verification::notes() const
{
    return m_notes;
}

QDateTime Verification::verifiedAt() const
{
    return m_verifiedAt;
}

void Verification::setNotes(const QString &newNotes)
{
    m_notes = newNotes;
    emit verificationNotesChanged();
}
