#ifndef IPAYMENTGATEWAY_H
#define IPAYMENTGATEWAY_H

#include <QObject>
#include "models/payment.h"

class IPaymentGateway : public QObject
{
    Q_OBJECT
public:
    explicit IPaymentGateway(QObject *parent = nullptr);
    virtual Payment processPayment() = 0;
    virtual Payment refundPayment() = 0;
};

#endif // IPAYMENTGATEWAY_H
