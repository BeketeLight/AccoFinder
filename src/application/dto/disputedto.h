#ifndef DISPUTEDTO_H
#define DISPUTEDTO_H

#include <QJsonObject>
#include <QString>
#include "models/dispute.h"
#include "core/utils/EDisputeStatus.h"

class DisputeDto
{
public:
    DisputeDto();
    DisputeDto(const QString &id,
                const QString &bookingId,
                const QString &issue,
                const DisputeStatus& status);


    QString m_id;
    QString m_bookingId;
    QString m_issue;
    DisputeStatus m_status;

    static DisputeDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    Dispute* toDomainModel() const;
};

#endif // DISPUTEDTO_H
