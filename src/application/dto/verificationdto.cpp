#include "verificationdto.h"

VerificationDto::VerificationDto()
    : m_id(),
    m_agentId(),
    m_propertyId(),
    m_notes(),
    m_verifiedAt(),
    m_status(VerificationStatus::NotVerified) // default assumption
{
}

VerificationDto::VerificationDto(const QString& id,
                                 const QString& agentId,
                                 const QString& propertyId,
                                 const QString& notes,
                                 const QDateTime& verifiedAt,
                                 VerificationStatus& status)
    : m_id(id),
    m_agentId(agentId),
    m_propertyId(propertyId),
    m_notes(notes),
    m_verifiedAt(verifiedAt),
    m_status(status)
{
}

// ---------------- JSON -> DTO ----------------

VerificationDto VerificationDto::fromJson(const QJsonObject& json)
{
    VerificationDto dto;

    dto.m_id = json["id"].toString();
    dto.m_agentId = json["agentId"].toString();
    dto.m_propertyId = json["propertyId"].toString();
    dto.m_notes = json["notes"].toString();

    dto.m_verifiedAt = QDateTime::fromString(json["verifiedAt"].toString(), Qt::ISODate);

    // assuming enum stored as int
    dto.m_status = static_cast<VerificationStatus>(json["status"].toInt());

    return dto;
}

// ---------------- DTO -> JSON ----------------

QJsonObject VerificationDto::toJson() const
{
    QJsonObject json;

    json["id"] = m_id;
    json["agentId"] = m_agentId;
    json["propertyId"] = m_propertyId;
    json["notes"] = m_notes;
    json["verifiedAt"] = m_verifiedAt.toString(Qt::ISODate);
    json["status"] = static_cast<int>(m_status);

    return json;
}

// ---------------- DTO -> Domain Model ----------------

Verification* VerificationDto::toDomainModel() const
{
    return new Verification(
        m_id,
        m_agentId,
        m_propertyId,
        m_notes,
        m_verifiedAt,
        m_status
        );
}