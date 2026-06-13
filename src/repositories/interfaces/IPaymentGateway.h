#ifndef IPAYMENTGATEWAY_H
#define IPAYMENTGATEWAY_H

#include <QObject>
#include "models/payment.h"
#include "core/utils/EPaymentStatus.h"

class IPaymentGateway : public QObject
{
    Q_OBJECT
public:
    explicit IPaymentGateway(QObject *parent = nullptr)
        : QObject(parent) {}
   // virtual Payment* processPayment() = 0;

    virtual void createPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate) =0; //initiating payment

    virtual void verifyPayment(const QString& id, double amount) = 0;

    virtual void getPaymentById(const QString& id) =0;
    //virtual void getAllPayments() =0;
    //virtual void callWebHook() = 0;
    virtual void cancelPayment(const QString& id, 
                       const QString& bookingId, 
                       double amount, 
                       const QString& method, 
                       const PaymentStatus& status,
                       const QString& transactionRef, 
                       const QString& payoutStatus, 
                       const QDateTime& payoutDate) =0;

    virtual ~IPaymentGateway() {}
};

#endif // IPAYMENTGATEWAY_H
