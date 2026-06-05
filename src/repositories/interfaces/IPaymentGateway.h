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
    virtual Payment* processPayment() = 0;
    virtual Payment* refundPayment() = 0;

    virtual ~IPaymentGateway() {}
};

#endif // IPAYMENTGATEWAY_H
