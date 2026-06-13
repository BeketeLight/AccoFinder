#include "paymentrepositoryimpl.h"
#include <QJsonObject>
#include "services/apiclient.h"


PaymentRepositoryImpl::PaymentRepositoryImpl(QObject *parent)
    : IPaymentGateway(parent) 
{

}
void  PaymentRepositoryImpl::createPayment(const QString& id, 
                                            const QString& bookingId, 
                                            double amount, 
                                            const QString& method, 
                                            const PaymentStatus& status,
                                            const QString& transactionRef, 
                                            const QString& payoutStatus, 
                                            const QDateTime& payoutDate)
{
    PaymentDto dto(id,bookingId,amount,status,transactionRef,payoutStatus,payoutDate);

    APIClient::instance().post(
        "api/payment/init" + bookingId,
        dto.toJson,
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PaymentDto updateDto = PaymentDto::fromJson(response["data"].toObject());
                Payment* payment = updateDto.toDomainModel();

                emit paymentProcessed(payment);
            }else{
                emit paymentError(response["error"].toString());
            }
        }
    )
}  

void PaymentRepositoryImpl::verifyPayment(const QString& id,    
                                         double amount)   
{
    //PaymentDto dto(id,bookingId,amount,status,transactionRef,payoutStatus,payoutDate);

    APIClient::instance().get(
        "api/payment/verify",
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PaymentDto updateDto = PaymentDto::fromJson(response["data"].toObject());
                Payment* payment = updateDto.toDomainModel();
                
                emit paymentRefunded(payment);
            }else{
                emit paymentError(response["error"].toString());
            }
        }
        
    )
} 

void PaymentRepositoryImpl::getPaymentById(const QString& id)
{
    APIClient::instance().get(
        "api/payments/user/:" + id,
        [this] (bool success, const QJSonObject& response)
        {
            if(success){
                PaymentDto updateDto = PaymentDto::fromJson(response["data"].toObject());
                Payment* payment = updateDto.toDomainModel();
                emit paymentLoaded(payment);
            }else{
                emit paymentError(response["error"].toString());
            }
        }
    )
}

void PaymentRepositoryImpl::cancelPayment(const QString& id,
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
        "api/payments/cancel",
        dto.toJson,
        [this] (bool success, const QString& response)
        {
            if(success){
                PaymentDto updateDto = PaymentDto::fromJson(response["data"].toObject);
                Payment* payment = updateDto.toDomainModel();
                
                emit paymentCalled(payment);
            }{
                else{
                    emit paymentError(response["error"].toString());
                }
            }
        }
    )
}