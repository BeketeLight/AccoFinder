#include "disputedto.h"

DisputeDto::DisputeDto() {}

DisputeDto::DisputeDto(const QString &id,
                       const QString &bookingId,
                       const QString &issue,
                       const DisputeStatus &status)
    :m_id(id),
    m_bookingId(bookingId),
    m_issue(issue),
    m_status(status)
{
    
}

DisputeDto DisputeDto::fromJson(const QJsonObject &json)
{
    DisputeDto dto;

    dto.m_id =
        json["id"].toString();

    dto.m_bookingId =
        json["bokingId"].toString();

    dto.m_issue =
        json["issue"].toString();

    QString statusStr =
        json["status"].toString();

    if(statusStr == "open")
    {
        dto.m_status = DisputeStatus::Open;
    }
    else if(statusStr == "resolved")
    {
        dto.m_status = DisputeStatus::Resolved;
    }
    return dto;
    
}

QJsonObject DisputeDto::toJson() const
{
    {
        QJsonObject json;

        json["id"] = m_id;
        json["bokingId"] = m_bookingId;
        json["issue"] = m_issue;
        switch(m_status)
        {
        case DisputeStatus::Open:
            json["status"] = "open";
            break;

        case DisputeStatus::Resolved:
            json["status"] = "resolved";
            break;
        }

        return json;
    }

}

Dispute *DisputeDto::toDomainModel() const
{
    Dispute* dispute = new Dispute();

    dispute->setId(m_id);
    dispute->setBookingId(m_bookingId);
    dispute->setIssue(m_issue);
    dispute->setStatus(m_status);


    return dispute;
    
}
