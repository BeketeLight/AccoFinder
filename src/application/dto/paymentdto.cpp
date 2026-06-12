#include "paymentdto.h"

PaymentDto::PaymentDto()
    : m_amount(0.0)
{
}

PaymentDto::PaymentDto(
    const QString& id,
    const QString& bookingId,
    double amount,
    const QString& method,
    const PaymentStatus& status,
    const QString& transactionRef,
    const QString& payoutStatus,
    const QDateTime& payoutDate)
    : m_id(id),
    m_bookingId(bookingId),
    m_amount(amount),
    m_method(method),
    m_status(status),
    m_transactionRef(transactionRef),
    m_payoutStatus(payoutStatus),
    m_payoutDate(payoutDate)
{
}

PaymentDto PaymentDto::fromJson(
    const QJsonObject& json)
{
    PaymentDto dto;

    dto.m_id =
        json["id"].toString();

    dto.m_bookingId =
        json["bookingId"].toString();

    dto.m_amount =
        json["amount"].toDouble();

    dto.m_method =
        json["method"].toString();

    QString statusStr =
        json["status"].toString();

    if(statusStr == "Initiated")
    {
        dto.m_status = PaymentStatus::Initiated;
    }
    else if(statusStr == "Success")
    {
        dto.m_status = PaymentStatus::Success;
    }
    else if(statusStr == "Failed")
    {
        dto.m_status = PaymentStatus::Failed;
    }

    dto.m_transactionRef =
        json["transactionRef"].toString();

    dto.m_payoutStatus =
        json["payoutStatus"].toString();

    dto.m_payoutDate =
        QDateTime::fromString(
            json["payoutDate"].toString(),
            Qt::ISODate
            );

    return dto;
}

QJsonObject PaymentDto::toJson() const
{
    QJsonObject json;

    json["id"] =
        m_id;

    json["bookingId"] =
        m_bookingId;

    json["amount"] =
        m_amount;

    json["method"] =
        m_method;
    switch(m_status)
    {
    case PaymentStatus::Initiated:
        json["status"] = "Initiated";
        break;

    case PaymentStatus::Success:
        json["status"] = "Success";
        break;

    case PaymentStatus::Failed:
        json["status"] = "Failed";
        break;
    }

    json["transactionRef"] =
        m_transactionRef;

    json["payoutStatus"] =
        m_payoutStatus;

    json["payoutDate"] =
        m_payoutDate.toString(
            Qt::ISODate
            );

    return json;
}

Payment* PaymentDto::toDomainModel() const
{
    return new Payment(
        m_id,
        m_bookingId,
        m_amount,
        m_method,
        m_status,
        m_transactionRef,
        m_payoutStatus,
        m_payoutDate
        );
}