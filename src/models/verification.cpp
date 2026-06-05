#include "verification.h"

Verification::Verification(QObject *parent)
    :QObject(parent)
{}

QString Verification::getId() const
{
    return id;
}

void Verification::setId(const QString &newId)
{
    id = newId;
}

QString Verification::getPropertyId() const
{
    return propertyId;
}

void Verification::setPropertyId(const QString &newPropertyId)
{
    propertyId = newPropertyId;
}

VerificationStatus Verification::getStatus() const
{
    return status;
}

void Verification::setStatus(VerificationStatus newStatus)
{
    status = newStatus;
}
