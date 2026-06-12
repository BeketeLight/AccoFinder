#ifndef PAYMENTGATEWAYIMPL_H
#define PAYMENTGATEWAYIMPL_H

#include "repositories/interfaces/IPaymentGateway.h"
#include "models/payment.h"

class PaymentGatewayImpl : public IPaymentGateway
{
public:
    PaymentGatewayImpl();
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
private:
    Payment* payment = new Payment;

};

#endif // PAYMENTGATEWAYIMPL_H
