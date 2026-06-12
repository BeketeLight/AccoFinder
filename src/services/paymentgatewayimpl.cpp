#include "paymentgatewayimpl.h"

PaymentGatewayImpl::PaymentGatewayImpl() {}

void PaymentGatewayImpl::processPayment(const QString& id, 
                                        const QString& bookingId, 
                                        double amount, 
                                        const QString& method, 
                                        const PaymentStatus& status,
                                        const QString& transactionRef, 
                                        const QString& payoutStatus, 
                                        const QDateTime& payoutDate)
{
    
}

void PaymentGatewayImpl::refundPayment(const QString& id, 
                                    const QString& bookingId, 
                                    double amount, 
                                    const QString& method, 
                                    const PaymentStatus& status,
                                    const QString& transactionRef, 
                                    const QString& payoutStatus, 
                                    const QDateTime& payoutDate)
{
    
}
