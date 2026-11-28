#include "disputedto.h"

#include <QJsonArray>
#include <QJsonValue>

#include <utility>

namespace {
QString stringOrId(const QJsonValue &value)
{
    if (value.isObject()) {
        const QJsonObject object = value.toObject();
        const QString id = object.value(QStringLiteral("_id")).toString();
        if (!id.isEmpty())
            return id;
        return object.value(QStringLiteral("id")).toString();
    }
    return value.toString();
}

DisputeStatus statusFromString(const QString &rawStatus)
{
    const QString status = rawStatus.trimmed().toLower();
    if (status == QStringLiteral("resolved"))
        return DisputeStatus::Resolved;
    if (status == QStringLiteral("rejected"))
        return DisputeStatus::Rejected;
    return DisputeStatus::Open;
}
} // namespace

DisputeDto::DisputeDto() = default;

DisputeDto::DisputeDto(const QString &id,
                       const QString &bookingId,
                       const QString &issue,
                       DisputeStatus status)
    : m_id(id),
      m_bookingId(bookingId),
      m_issue(issue),
      m_status(status)
{
}

DisputeDto DisputeDto::fromJson(const QJsonObject &json)
{
    DisputeDto dto;

    dto.m_id = stringOrId(json.value(QStringLiteral("_id")));
    if (dto.m_id.isEmpty())
        dto.m_id = stringOrId(json.value(QStringLiteral("id")));

    // The API populates bookingId as an object on list/detail responses and as
    // a bare id on create/update responses. Accept both.
    dto.m_bookingId = stringOrId(json.value(QStringLiteral("bookingId")));

    dto.m_issue = json.value(QStringLiteral("issue")).toString();
    if (dto.m_issue.isEmpty())
        dto.m_issue = json.value(QStringLiteral("description")).toString();

    dto.m_status = statusFromString(json.value(QStringLiteral("status")).toString());
    return dto;
}

DisputeDto DisputeDto::fromApiResponse(const QJsonObject &response)
{
    const QJsonValue data = response.value(QStringLiteral("data"));
    if (data.isObject())
        return fromJson(data.toObject());
    return fromJson(response);
}

QList<DisputeDto> DisputeDto::listFromApiResponse(const QJsonObject &response)
{
    QList<DisputeDto> disputes;

    const QJsonValue data = response.value(QStringLiteral("data"));
    QJsonArray array;
    if (data.isArray()) {
        array = data.toArray();
    } else if (data.isObject()) {
        const QJsonObject object = data.toObject();
        const QJsonValue nested = object.value(QStringLiteral("disputes"));
        if (nested.isArray())
            array = nested.toArray();
    }

    for (const QJsonValue &value : std::as_const(array)) {
        if (value.isObject())
            disputes.append(fromJson(value.toObject()));
    }
    return disputes;
}

QJsonObject DisputeDto::toJson() const
{
    QJsonObject json;
    json[QStringLiteral("id")] = m_id;
    json[QStringLiteral("bookingId")] = m_bookingId;
    json[QStringLiteral("issue")] = m_issue;

    switch (m_status) {
    case DisputeStatus::Resolved:
        json[QStringLiteral("status")] = QStringLiteral("resolved");
        break;
    case DisputeStatus::Rejected:
        json[QStringLiteral("status")] = QStringLiteral("rejected");
        break;
    case DisputeStatus::Open:
    default:
        json[QStringLiteral("status")] = QStringLiteral("open");
        break;
    }
    return json;
}

Dispute *DisputeDto::toDomainModel(QObject *parent) const
{
    return new Dispute(m_id, m_bookingId, m_issue, m_status, parent);
}
