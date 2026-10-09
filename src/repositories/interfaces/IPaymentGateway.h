#ifndef IPAYMENTGATEWAY_H
#define IPAYMENTGATEWAY_H

#include <QObject>
#include <QVariantList>
#include "models/payment.h"
#include "core/utils/EPaymentStatus.h"

class IPaymentGateway : public QObject
{
    Q_OBJECT
public:
    explicit IPaymentGateway(QObject *parent = nullptr)
        : QObject(parent) {}
   // virtual Payment* processPayment() = 0;

    virtual void createPayment(const QString& bookingId,
                               double amount,
                               const QString& method,
                               const QString& operatorRefId,
                               const QString& phoneNumber) =0;

    virtual void verifyPayment(const QString& chargeId) = 0;
    virtual void fetchOperators() = 0;

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
signals:
    void operatorsLoaded(const QVariantList& operators);
    void operatorsError(const QString& error);
    void paymentVerified(Payment* payment);
    void paymentVerificationPending(Payment* payment);
};

#endif // IPAYMENTGATEWAY_H
