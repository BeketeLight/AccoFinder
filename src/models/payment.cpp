#include "payment.h"

Payment::Payment(QObject *parent)
    :QObject(parent)
{}
Payment::Payment(const QString &newId,
                 const QString &newBookingId,
                 double newAmount,
                 const QString &newMethod,
                 PaymentStatus newStatus,
                 const QString &newTransactionRef,
                 const QString &newPayoutStatus,
                 const QDateTime &newPayoutDate,
                 QObject *parent)
    :id(newId)
    ,bookingId(newBookingId)
    ,amount(newAmount)
    ,status(newStatus)
    ,transactionalRef(newTransactionRef)
    ,payoutStatus(newPayoutStatus)
    ,payoutDate(newPayoutDate)
    ,QObject(parent)
{
    emit paymentCreated();
    emit paymentProcessed();
}
QString Payment::getId() const
{
    return id;
}

void Payment::setId(const QString &newId)
{
    id = newId;
}

QString Payment::getBookingId() const
{
    return bookingId;
}

void Payment::setBookingId(const QString &newBookingId)
{
    bookingId = newBookingId;
}

double Payment::getAmount() const
{
    return amount;
}

void Payment::setAmount(double newAmount)
{
    amount = newAmount;
}

QString Payment::getMethod() const
{
    return method;
}

void Payment::setMethod(const QString &newMethod)
{
    method = newMethod;
}

PaymentStatus Payment::getStatus() const
{
    return status;
}

void Payment::setStatus(PaymentStatus newStatus)
{
    status = newStatus;
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
    return transactionalRef;
}

void Payment::setTransactionalRef(const QString &newTransactionalRef)
{
    transactionalRef = newTransactionalRef;
}

QString Payment::getPayoutStatus() const
{
    return payoutStatus;
}

void Payment::setPayoutStatus(const QString &newPayoutStatus)
{
    payoutStatus = newPayoutStatus;
}

QDateTime Payment::getPayoutDate() const
{
    return payoutDate;
}

void Payment::setPayoutDate(const QDateTime &newPayoutDate)
{
    payoutDate = newPayoutDate;
}
