#include "paymentdto.h"

// ---------------------------------------------------------------------------
// Status <-> string helpers
// These map the backend enum strings (from PaymentStatus.mjs) to the C++ enum.
// The backend emits uppercase: INITIATED, SUCCESS, FAILED, PENDING, REFUNDED.
// ---------------------------------------------------------------------------
static PaymentStatus statusFromString(const QString& s)
{
    const QString v = s.trimmed().toUpper();

    if (v == "INITIATED") return PaymentStatus::Initiated;
    if (v == "SUCCESS")   return PaymentStatus::Success;
    if (v == "FAILED")    return PaymentStatus::Failed;
    if (v == "PENDING")   return PaymentStatus::Pending;
    if (v == "REFUNDED")  return PaymentStatus::Refunded;

    // Unknown or empty -> Initiated (safe default for a new payment)
    return PaymentStatus::Initiated;
}

static QString statusToString(PaymentStatus s)
{
    switch (s) {
    case PaymentStatus::Initiated: return "INITIATED";
    case PaymentStatus::Success:   return "SUCCESS";
    case PaymentStatus::Failed:    return "FAILED";
    case PaymentStatus::Pending:   return "PENDING";
    case PaymentStatus::Refunded:  return "REFUNDED";
    }
    return "INITIATED";
}

// ---------------------------------------------------------------------------

PaymentDto::PaymentDto()
    : m_amount(0.0)
    , m_status(PaymentStatus::Initiated)
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
    const QDateTime& payoutDate,
    const QDateTime& paidAt)
    : m_id(id)
    , m_bookingId(bookingId)
    , m_amount(amount)
    , m_method(method)
    , m_status(status)
    , m_transactionRef(transactionRef)
    , m_payoutStatus(payoutStatus)
    , m_payoutDate(payoutDate)
    , m_paidAt(paidAt)
{
}

PaymentDto PaymentDto::fromJson(const QJsonObject& json)
{
    PaymentDto dto;

    // Support both Mongo's "_id" and the serializer's "id".
    dto.m_id = json.contains("_id")
                   ? json.value("_id").toString()
                   : json.value("id").toString();

    dto.m_bookingId     = json.value("bookingId").toString();
    dto.m_amount        = json.value("amount").toDouble();
    dto.m_method        = json.value("method").toString();
    dto.m_status        = statusFromString(json.value("status").toString());
    dto.m_transactionRef = json.value("transactionRef").toString();
    dto.m_payoutStatus  = json.value("payoutStatus").toString();

    dto.m_payoutDate = QDateTime::fromString(
        json.value("payoutDate").toString(), Qt::ISODate);

    dto.m_paidAt = QDateTime::fromString(
        json.value("paidAt").toString(), Qt::ISODate);

    return dto;
}

QJsonObject PaymentDto::toJson() const
{
    QJsonObject json;

    json["id"]             = m_id;
    json["bookingId"]      = m_bookingId;
    json["amount"]         = m_amount;
    json["method"]         = m_method;
    json["status"]         = statusToString(m_status);
    json["transactionRef"] = m_transactionRef;
    json["payoutStatus"]   = m_payoutStatus;

    if (m_payoutDate.isValid())
        json["payoutDate"] = m_payoutDate.toString(Qt::ISODate);

    if (m_paidAt.isValid())
        json["paidAt"] = m_paidAt.toString(Qt::ISODate);

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
        m_payoutDate,
        m_paidAt
        );
}