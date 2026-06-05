#ifndef PAYMENT_H
#define PAYMENT_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include "core/utils/EPaymentStatus.h"

class Payment : public QObject
{
    Q_OBJECT
public:
    explicit Payment(QObject *parent = nullptr);
    QString getId() const;
    void setId(const QString &newId);
    QString getBookingId() const;
    void setBookingId(const QString &newBookingId);
    double getAmount() const;
    void setAmount(double newAmount);
    QString getMethod() const;
    void setMethod(const QString &newMethod);
    PaymentStatus getStatus() const;
    void setStatus(PaymentStatus newStatus);
    QString getTransactionalRef() const;
    void setTransactionalRef(const QString &newTransactionalRef);
    QString getPayoutStatus() const;
    void setPayoutStatus(const QString &newPayoutStatus);
    QDateTime getPayoutDate() const;
    void setPayoutDate(const QDateTime &newPayoutDate);

private:
    QString id;
    QString bookingId;
    double amount;
    QString method;
    PaymentStatus status;
    QString transactionalRef;
    QString payoutStatus;
    QDateTime payoutDate;

signals:
    void paymentProcessed();
    void paymentFailed();

};

#endif // PAYMENT_H
