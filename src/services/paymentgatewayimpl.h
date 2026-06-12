#ifndef PAYMENTGATEWAYIMPL_H
#define PAYMENTGATEWAYIMPL_H

#include "repositories/interfaces/IPaymentGateway.h"
#include "models/payment.h"

class PaymentGatewayImpl : public IPaymentGateway
{
public:
    PaymentGatewayImpl();
    Payment* refundPayment() override;
Payment* createPayment() override;
    Payment* getPaymentById(const QString& id) override;
    QList<Payment*> getAllPayments() override;
    PaymentStatus* getPaymentStatus(const QString& id) override;
private:
    Payment* payment = new Payment;

};

#endif // PAYMENTGATEWAYIMPL_H
