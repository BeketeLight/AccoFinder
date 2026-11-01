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
        json.contains("_id")
            ? json["_id"].toString()
            : json["id"].toString();

    dto.m_bookingId =
        json.contains("bookingId")
            ? json["bookingId"].toString()
            : json["bokingId"].toString();

    dto.m_issue =
        json["issue"].toString();

    QString statusStr =
        json["status"].toString();

    if(statusStr == "open" || statusStr == "Open")
    {
        dto.m_status = DisputeStatus::Open;
    }
    else if(statusStr == "resolved" || statusStr == "Resolved")
    {
        dto.m_status = DisputeStatus::Resolved;
    }
    else if(statusStr == "rejected" || statusStr == "Rejected")
    {
        dto.m_status = DisputeStatus::Rejected;
    }
    return dto;
    
}

QJsonObject DisputeDto::toJson() const
{
    {
        QJsonObject json;

        json["id"] = m_id;
        json["bookingId"] = m_bookingId;
        json["issue"] = m_issue;
        switch(m_status)
        {
        case DisputeStatus::Open:
            json["status"] = "open";
            break;

        case DisputeStatus::Resolved:
            json["status"] = "resolved";
            break;

        case DisputeStatus::Rejected:
            json["status"] = "rejected";
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
