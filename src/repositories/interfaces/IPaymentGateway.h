#ifndef IPAYMENTGATEWAY_H
#define IPAYMENTGATEWAY_H

#include <QObject>
#include "models/payment.h"

class IPaymentGateway : public QObject
{
    Q_OBJECT
public:
    explicit IPaymentGateway(QObject *parent = nullptr)
        : QObject(parent) {}
    
    virtual void processPayment(const QString& id, 
                                const QString& bookingId, 
                                double amount, 
                                const QString& method, 
                                const PaymentStatus& status,
                                const QString& transactionRef, 
                                const QString& payoutStatus, 
                                const QDateTime& payoutDate) = 0;

    virtual void refundPayment(const QString& id, 
                              const QString& bookingId, 
                              double amount, 
                              const QString& method, 
                              const PaymentStatus& status,
                              const QString& transactionRef, 
                              const QString& payoutStatus, 
                              const QDateTime& payoutDate) = 0;

    virtual ~IPaymentGateway() {}
};

#endif // IPAYMENTGATEWAY_H
