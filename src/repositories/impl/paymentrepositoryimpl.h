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
    
    void createPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate) override;

    void verifyPayment(const QString& id, double amount) override;

    void getPaymentById(const QString& id) override;

   //void getAllPayments() override;

    void cancelPayment(const QString& id,  
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate) override;

signals:
    void paymentCreated(Payment* payment);
    void paymentVerified(Payment* payment);
    void paymentLoaded(Payment* payment);
    void paymentCalled(Payment* payment);
    void paymentError(const QString& error);
};

#endif
