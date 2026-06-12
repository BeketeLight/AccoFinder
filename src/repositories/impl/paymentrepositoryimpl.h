#ifndef PAYMENTREPOSITORYIMPL_H
#define PAYMENTREPOSITORYIMPL_H

#include "repositories/interfaces/IPaymentGateway.h"
#include "application/dto/paymentdto.h"
#include  "models/payment.h"

class PaymentRepositoryImpl : public IPaymentGateway
{
    Q_OBJECT
public:
    explicit PaymentRepositoryImpl(QObject *parent = nullptr);
    
    void processPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate) override;

    void refundPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate) override;

signals:
    void paymentProcessed(Payment* payment);
    void paymentRefunded(Payment* payment);
    void paymentError(const QString& error);
};

#endif
