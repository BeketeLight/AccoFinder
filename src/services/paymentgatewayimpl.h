#ifndef PAYMENTGATEWAYIMPL_H
#define PAYMENTGATEWAYIMPL_H

#include "repositories/interfaces/IPaymentGateway.h"
#include "models/payment.h"

class PaymentGatewayImpl : public IPaymentGateway
{
public:
    PaymentGatewayImpl();
    Payment* processPayment() override;
    Payment* refundPayment() override;
private:
    Payment* payment = new Payment;

};

#endif // PAYMENTGATEWAYIMPL_H
