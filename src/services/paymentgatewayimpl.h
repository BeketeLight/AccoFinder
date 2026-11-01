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
    PaymentGatewayImpl(QObject* parent = nullptr);
    void verifyPayment(const QString& chargeId) override;

    void createPayment(const QString& bookingId,
                       double amount, 
                       const QString& method,
                       const QString& operatorRefId,
                       const QString& phoneNumber) override;

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
    void fetchOperators() override;

    void settleCommission(const QString& paymentId,
                          const QString& bookingId,
                          const QString& agentId,
                          const QString& agentName) override;

    void releasePayout(const QString& paymentId,
                       const QString& bookingId,
                       const QString& landlordId,
                       const QString& landlord) override;

    void refundPayment(const QString& paymentId,
                      const QString& bookingId,
                      const QString& transactionRef,
                      const QString& reason) override;

signals:
    void paymentCreated(Payment* payment);
    void paymentVerified(Payment* payment);
    void paymentLoaded(Payment* payment);
    void paymentCancelled(Payment* payment);
    void paymentError(const QString& error);
    void paymentVerificationPending(Payment* payment);
    void commissionSettled(const QJsonObject& data);
    void payoutReleased(const QJsonObject& data);
    void paymentRefunded(const QJsonObject& data);

};

#endif // PAYMENTGATEWAYIMPL_H
