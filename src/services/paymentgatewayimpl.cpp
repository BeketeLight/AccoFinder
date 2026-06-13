#include "paymentgatewayimpl.h"

PaymentGatewayImpl::PaymentGatewayImpl() {}

Payment *PaymentGatewayImpl::refundPayment()
{
    return payment;
}

Payment *PaymentGatewayImpl::createPayment()
{

}

Payment *PaymentGatewayImpl::getPaymentById(const QString &id)
{

}

QList<Payment *> PaymentGatewayImpl::getAllPayments()
{

}

PaymentStatus *PaymentGatewayImpl::getPaymentStatus(const QString &id)
{

}
