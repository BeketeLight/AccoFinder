#include "payment.h"

Payment::Payment(QObject *parent)
    :QObject(parent)
{}
Payment::Payment(const QString &id,
                 const QString &bookingId,
                 double amount,
                 const QString &method,
                 PaymentStatus status,
                 const QString &transactionRef,
                 const QString &payoutStatus,
                 const QDateTime &payoutDate,
                 QObject *parent)
    :m_id(id)
    ,m_bookingId(bookingId)
    ,m_amount(amount)
    ,m_status(status)
    ,m_transactionalRef(transactionRef)
    ,m_payoutStatus(payoutStatus)
    ,m_payoutDate(payoutDate)
    ,QObject(parent)
{
    emit paymentCreated();
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
    m_status = status;
    if (getStatus() == PaymentStatus::Failed)
    {
        emit paymentFailed();
    }
    else if (getStatus() == PaymentStatus::Success)
    {
        emit paymentProcessed();
    }
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


