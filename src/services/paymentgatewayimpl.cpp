#include "paymentgatewayimpl.h"

PaymentGatewayImpl::PaymentGatewayImpl() {}

void PaymentGatewayImpl::verifyPayment(const QString& id, double amount)
{
    
}
void PaymentGatewayImpl::createPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate)
{

}

void PaymentGatewayImpl::getPaymentById(const QString &id)
{

}
void PaymentGatewayImpl::cancelPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate)
{

}

// QList<Payment *> PaymentGatewayImpl::getAllPayments()
// {

// }

