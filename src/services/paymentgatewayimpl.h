#ifndef PAYMENTGATEWAYIMPL_H
#define PAYMENTGATEWAYIMPL_H

#include "repositories/interfaces/IPaymentGateway.h"
#include "models/payment.h"

class PaymentGatewayImpl : public IPaymentGateway
{
public:
    PaymentGatewayImpl();
    void verifyPayment(const QString& id, double amount) override;

    void createPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate) override;

    void getPaymentById(const QString& id) override;

    void cancelPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate)override;
    //void getAllPayments() override;
    //virtual void callWebHook() = 0;
    
private:
    Payment* payment = new Payment;

};

#endif // PAYMENTGATEWAYIMPL_H
