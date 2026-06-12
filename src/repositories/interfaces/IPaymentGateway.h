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
    virtual Payment* refundPayment() = 0;
    virtual Payment* createPayment() =0;
    virtual Payment* getPaymentById(const QString& id) =0;
    virtual QList<Payment*> getAllPayments() =0;
    virtual PaymentStatus* getPaymentStatus(const QString& id) =0;

    virtual ~IPaymentGateway() {}
};

#endif // IPAYMENTGATEWAY_H
