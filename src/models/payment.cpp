#include "payment.h"

Payment::Payment(QObject *parent)
    :QObject(parent)
{}
Payment::Payment(const QString& id,
                 const QString& bookingId,
                 double amount,
                 const QString& method,
                 PaymentStatus status,
                 const QString& transactionRef,
                 const QString& payoutStatus,
                 const QDateTime& payoutDate,
                 const QDateTime& paidAt,
                 QObject* parent)
    : QObject(parent)
    , m_id(id)
    , m_bookingId(bookingId)
    , m_amount(amount)
    , m_method(method)
    , m_status(status)
    , m_transactionalRef(transactionRef)
    , m_payoutStatus(payoutStatus)
    , m_payoutDate(payoutDate)
    , m_paidAt(paidAt)
{
    // No emit here. The gateway emits paymentCreated after construction.
}
QString Payment::getId() const
{
    return m_id;
}

QString Payment::getBookingId() const
{
    return m_bookingId;
}


double Payment::getAmount() const
{
    return m_amount;
}


QString Payment::getMethod() const
{
    return m_method;
}

PaymentStatus Payment::getStatus() const
{
    return m_status;
}

void Payment::setStatus(PaymentStatus status)
{
    if (m_status == status) return;
    m_status = status;
    if (getStatus() == PaymentStatus::Failed)
    {
        emit paymentFailed();
    }
    else if (getStatus() == PaymentStatus::Success)
    {
        emit paymentProcessed();
    }
    emit statusChanged();
}

QString Payment::getTransactionalRef() const
{
    return m_transactionalRef;
}


QString Payment::getPayoutStatus() const
{
    return m_payoutStatus;
}

QDateTime Payment::getPayoutDate() const
{
    return m_payoutDate;
}

QDateTime Payment::getPaidAt() const
{
    return m_paidAt;
}


