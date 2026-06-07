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
    Payment(const QString& id,
            const QString& bookingId,
            double amount,
            const QString& method,
            PaymentStatus status,
            const QString& transactionRef = "",
            const QString& payoutStatus = "",
            const QDateTime& payoutDate = QDateTime(),
            QObject* parent = nullptr);
    QString getId() const;

    QString getBookingId() const;

    double getAmount() const;
    QString getMethod() const;
    PaymentStatus getStatus() const;
    void setStatus(PaymentStatus status);
    QString getTransactionalRef() const;
    QString getPayoutStatus() const;
    QDateTime getPayoutDate() const;
private:
    QString m_id;
    QString m_bookingId;
    double m_amount;
    QString m_method;
    PaymentStatus m_status;
    QString m_transactionalRef;
    QString m_payoutStatus;
    QDateTime m_payoutDate;

signals:
    void paymentProcessed();
    void paymentFailed();
    void paymentCreated();

};

#endif // PAYMENT_H
