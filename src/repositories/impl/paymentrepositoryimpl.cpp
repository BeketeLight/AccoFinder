#include "paymentrepositoryimpl.h"
#include <QJsonObject>
#include "services/apiclient.h"


PaymentRepositoryImpl::PaymentRepositoryImpl(QObject *parent)
    : IPaymentGateway(parent) 
{

}
void  PaymentRepositoryImpl::processPayment(const QString& id, 
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
        "api/payment:/" + bookingId,
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

void PaymentRepositoryImpl::refundPayment(const QString& id, 
                                       const QString& bookingId, 
                                       double amount, 
                                       const QString& method, 
                                       const PaymentStatus& status,
                                       const QString& transactionRef, 
                                       const QString& payoutStatus, 
                                       const QDateTime& payoutDate)   
{
    PaymentDto dto(id,bookingId,amount,status,transactionRef,payoutStatus,payoutDate);

    APIClient::instance().patch(
        "api/payment/:" + bookingId,
        dto.toJson,
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