#include "paymentgatewayimpl.h"
#include <QJsonObject>
#include <QJsonArray>

PaymentGatewayImpl::PaymentGatewayImpl(QObject* parent)
    : IPaymentGateway(parent)
     
{

}
void  PaymentGatewayImpl::createPayment(const QString& bookingId,
                                        double amount,
                                        const QString& method,
                                        const QString& operatorRefId,
                                        const QString& phoneNumber)
{
    QJsonObject body{
        { "bookingId", bookingId },
        { "amount",    amount },
        };
    if (!operatorRefId.isEmpty()) body["operatorRefId"] = operatorRefId;
    if (!phoneNumber.isEmpty())   body["phoneNumber"]   = phoneNumber;
    // if (!method.isEmpty())        body["method"]        = method;

    APIClient::instance().post(
        QString("/payments/process/%1").arg(bookingId),
        body,
        [this] (bool success, const QJsonObject& response)
        {
            if (!success) {
                emit paymentError(
                    response.value("message").toString("Payment failed to start"));
                return;
            }
            // The backend wraps payloads as { success, message, data }.
            const QJsonObject data = response.value("data").toObject();
            const QJsonObject p = data.value("payment").toObject();
            QJsonObject withRef = p;
            if (!withRef.contains("transactionRef"))
                withRef["transactionRef"] = data.value("tx_ref").toString();
            if (withRef.isEmpty()) {
                emit paymentError(response.value("message").toString("Payment failed to start"));
                return;
            }
            auto* payment = PaymentDto::fromJson(withRef).toDomainModel();
            emit paymentCreated(payment);
        }
    );
}  

void PaymentGatewayImpl::verifyPayment(const QString& chargeId)
{
    //PaymentDto dto(id,bookingId,amount,status,transactionRef,payoutStatus,payoutDate);

    APIClient::instance().get(
        QString("/payments/verify/%1").arg(chargeId),
        [this] (bool success, const QJsonObject& response)
        {
            if (!success) {
                emit paymentError(
                    response.value("message").toString("Verification failed"));
                return;
            }

            const QJsonObject data = response.value("data").toObject();
            const QJsonObject p = data.value("payment").toObject();

            // Backend returns payment: null while PayChangu is still settling.
            // Treat that as pending, not as an error.
            if (p.isEmpty()) {
                emit paymentVerificationPending(nullptr);
                return;
            }
            // Merge bookingOutcome into the payment JSON so fromJson can read it.
            QJsonObject merged = p;
            const QJsonObject outcome = data.value("bookingOutcome").toObject();
            merged["bookingConfirmed"]     = outcome.value("confirmed").toBool();
            merged["bookingOutcomeReason"] = outcome.value("reason").toString();

            auto* payment = PaymentDto::fromJson(merged).toDomainModel();
            if(payment->getStatus() == PaymentStatus::Success ||
                payment->getStatus() == PaymentStatus::Failed){
                emit paymentVerified(payment);
            }else{
                emit paymentVerificationPending(payment);
            }
        }
        
    );
}



void PaymentGatewayImpl::getPaymentById(const QString& id)
{
    APIClient::instance().get(
        "/payments/user/" + id,
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PaymentDto updateDto = PaymentDto::fromJson(response["data"].toObject());
                Payment* payment = updateDto.toDomainModel();
                emit paymentLoaded(payment);
            }else{
                emit paymentError(response.value("message").toString());
            }
        }
    );
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
    PaymentDto dto(id,bookingId,amount,method,status, transactionRef,payoutStatus,payoutDate);

    APIClient::instance().post(
        "/payments/cancel",
        dto.toJson(),
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PaymentDto updateDto = PaymentDto::fromJson(response["data"].toObject());
                Payment* payment = updateDto.toDomainModel();
                emit paymentCancelled(payment);
            }
             else{
                emit paymentError(response["error"].toString());
             }
        }
    );    
}

void PaymentGatewayImpl::settleCommission(const QString& paymentId,
                                          const QString& bookingId,
                                          const QString& agentId,
                                          const QString& agentName)
{
    QJsonObject body;
    if (!paymentId.isEmpty()) body["paymentId"] = paymentId;
    if (!bookingId.isEmpty()) body["bookingId"] = bookingId;
    if (!agentId.isEmpty())   body["agentId"]   = agentId;
    if (!agentName.isEmpty()) body["agentName"] = agentName;

    APIClient::instance().post(
        "/payments/commissions/settle",
        body,
        [this](bool success, const QJsonObject& response)
        {
            if (!success) {
                emit paymentError(
                    response.value("message").toString("Could not settle commission"));
                return;
            }
            emit commissionSettled(response.value("data").toObject());
        }
    );
}

void PaymentGatewayImpl::releasePayout(const QString& paymentId,
                                       const QString& bookingId,
                                       const QString& landlordId,
                                       const QString& landlord)
{
    QJsonObject body;
    if (!paymentId.isEmpty())  body["paymentId"]  = paymentId;
    if (!bookingId.isEmpty())  body["bookingId"]  = bookingId;
    if (!landlordId.isEmpty()) body["landlordId"] = landlordId;
    if (!landlord.isEmpty())   body["landlord"]   = landlord;

    APIClient::instance().post(
        "/payments/payouts/release",
        body,
        [this](bool success, const QJsonObject& response)
        {
            if (!success) {
                emit paymentError(
                    response.value("message").toString("Could not release payout"));
                return;
            }
            emit payoutReleased(response.value("data").toObject());
        }
    );
}

void PaymentGatewayImpl::refundPayment(const QString& paymentId,
                                       const QString& bookingId,
                                       const QString& transactionRef,
                                       const QString& reason)
{
    QJsonObject body;
    if (!paymentId.isEmpty())      body["paymentId"]      = paymentId;
    if (!bookingId.isEmpty())      body["bookingId"]      = bookingId;
    if (!transactionRef.isEmpty()) body["transactionRef"] = transactionRef;
    if (!reason.isEmpty())         body["reason"]         = reason;

    APIClient::instance().post(
        "/payments/refund",
        body,
        [this](bool success, const QJsonObject& response)
        {
            if (!success) {
                emit paymentError(
                    response.value("message").toString("Could not refund payment"));
                return;
            }
            emit paymentRefunded(response.value("data").toObject());
        }
    );
}

void PaymentGatewayImpl::fetchOperators()
{
    APIClient::instance().get(
        "/payments/operators",
        [this](bool ok, const QJsonObject& resp) {
            if (!ok) {
                emit operatorsError(
                    resp.value("message").toString("Could not load operators"));
                return;
            }
            QVariantList list;
            qDebug()<<"avaible opoarators";
            qDebug()<<resp.value("data").toArray();
            for (const auto& v : resp.value("data").toArray())
                list.append(v.toObject().toVariantMap());
            emit operatorsLoaded(list);
        }
        );
}
// QList<Payment *> PaymentGatewayImpl::getAllPayments()
// {

// }

