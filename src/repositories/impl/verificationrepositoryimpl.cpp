#include "verificationrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonArray>
#include "services/apiclient.h"
#include <QList>


VerificationRepositoryImpl::VerificationRepositoryImpl(QObject *parent) 
    : IVerificationRepository(parent)
{

}

void VerificationRepositoryImpl::createVerification(const QString& id,
                                                   const QString& agentId, 
                                                   const QString& propertyId,
                                                   const QString& notes, 
                                                   const QDateTime& verifiedAt,
                                                   VerificationStatus& status)
{
    VerificationDto dto(id,agentId,propertyId,notes,verifiedAt,status);

    APIClient::instance().post(
        "api/property/:" + id,
        dto.toJson(),
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                VerificationDto updateDto = VerificationDto::fromJson(response["data"].toObject());
                Verification* verification = updateDto.toDomainModel();

                emit propertyCreated(verification);
            }else{
                emit propertyError(response["error"].toString());
            }
        }
    );
}                                                    
    

void VerificationRepositoryImpl::getVerificationHistory()
{
    APIClient::instance().get(
        "/api/property/history",
        [this]  (bool success, const QJsonObject& response)  
        {   QList<Verification*> verifications;
            if(success && response.contains("data")){
              QJsonArray dataArray = response["data"].toArray();
              for(const QJsonValue& value: std::as_const(dataArray)){
                VerificationDto dto = VerificationDto::fromJson(value.toObject());
                verifications.append(dto.toDomainModel());
              }
              emit propertyHistoryLoaded(verifications);
            }else{
                emit propertyError(response["error"].toString());
            }
        }
    );
}

void VerificationRepositoryImpl::approveProperty(const QString& id, 
                                                const QString& agentId, 
                                                const QString& propertyId, 
                                                const QString& notes, 
                                                const QDateTime& verifiedAt, 
                                                VerificationStatus& status)
{
    VerificationDto dto(id,agentId,propertyId,notes,verifiedAt,status);

    APIClient::instance().patch(
        "api/property/:" + propertyId,
        dto.toJson(),
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                VerificationDto updatedADto = VerificationDto::fromJson(response["data"].toObject());
                Verification* verification = updatedADto.toDomainModel();
                
                emit propertyApproved(verification);
            }else{
                emit propertyError(response["error"].toString());
            }
        }
    );

}
void VerificationRepositoryImpl::rejectProperty(const QString& id, 
                                                const QString& agentId, 
                                                const QString& propertyId, 
                                                const QString& notes, 
                                                const QDateTime& verifiedAt, 
                                                VerificationStatus& status)
{
    VerificationDto dto(id,agentId,propertyId,notes,verifiedAt,status);

    APIClient::instance().patch(
        "api/property:" + propertyId,
        dto.toJson(),
        [this] (bool success,const QJsonObject& response)
        {
            if(success){
                VerificationDto updatedDto = VerificationDto::fromJson(response["data"].toObject());
                Verification* verification = updatedDto.toDomainModel();

                emit propertyRejected(verification);
            }else{
                emit propertyError(response["error"].toString());
            }
        }
    );

}
