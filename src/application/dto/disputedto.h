#ifndef DISPUTEDTO_H
#define DISPUTEDTO_H

#include <QJsonObject>
#include <QList>
#include <QMetaType>
#include <QString>
#include "models/dispute.h"
#include "core/utils/EDisputeStatus.h"

// Plain value object used at the repository/controller/view-model boundary.
// Passing values (instead of shared raw Dispute*) keeps one response from
// deleting objects that another layer still holds.
class DisputeDto
{
public:
    DisputeDto();
    DisputeDto(const QString &id,
               const QString &bookingId,
               const QString &issue,
               DisputeStatus status);

    QString m_id;
    QString m_bookingId;
    QString m_issue;
    DisputeStatus m_status = DisputeStatus::Open;

    static DisputeDto fromJson(const QJsonObject &json);
    static DisputeDto fromApiResponse(const QJsonObject &response);
    static QList<DisputeDto> listFromApiResponse(const QJsonObject &response);

    QJsonObject toJson() const;

    // The returned Dispute is parented to `parent`, so the model that stores it
    // owns it. Never hand this pointer to a second owner.
    Dispute *toDomainModel(QObject *parent = nullptr) const;
};

Q_DECLARE_METATYPE(DisputeDto)
Q_DECLARE_METATYPE(QList<DisputeDto>)

#endif // DISPUTEDTO_H
