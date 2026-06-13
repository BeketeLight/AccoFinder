#ifndef PAYMENTGATEWAYIMPL_H
#define PAYMENTGATEWAYIMPL_H

#include "repositories/interfaces/IPaymentGateway.h"
#include "application/dto/paymentdto.h"
#include "services/apiclient.h"
#include "models/payment.h"

class PaymentGatewayImpl : public IPaymentGateway
{
    Q_OBJECT
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
    
signals:
    void paymentCreated(Payment* payment);
    void paymentVerified(Payment* payment);
    void paymentLoaded(Payment* payment);
    void paymentCancelled(Payment* payment);
    void paymentError(const QString& error);
    

};

#endif // PAYMENTGATEWAYIMPL_H
