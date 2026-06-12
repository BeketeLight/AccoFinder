#ifndef VERIFICATIONDTO_H
#define VERIFICATIONDTO_H

#include <QJsonObject>
#include <QDateTime>
#include <QString>
#include "models/verification.h"
#include "core/utils/EVerificationStatus.h"

class VerificationDto
{
public:
    VerificationDto();
    VerificationDto(const QString& id,
                    const QString& agentId,
                    const QString& propertyId,
                    const QString& notes,
                    const QDateTime& verifiedAt,
                    VerificationStatus& status);

    QString m_id;
    QString m_agentId;
    QString m_propertyId;
    QString m_notes;
    QDateTime m_verifiedAt;
    VerificationStatus m_status;


    static VerificationDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    Verification* toDomainModel() const;
};
#endif // VERIFICATIONDTO_H
