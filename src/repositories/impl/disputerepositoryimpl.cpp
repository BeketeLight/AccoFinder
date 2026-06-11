#include "disputerepositoryimpl.h"
#include "services/apiclient.h"
#include <QJsonObject>
#include <QJsonValue>
#include <QList>
#include <QJsonArray>

DisputeRepositoryImpl::DisputeRepositoryImpl(QObject *parent)
    :IDisputeRepository(parent)
{

}

void DisputeRepositoryImpl::raiseDispute(const QString& raisedBy,
        const QString& title,
        const QString& status,
        const QString& description)
{
    QJsonObject payload;
    payload["raisedBy"] = raisedBy;
    payload["title"] = title;
    payload["status"] = status;
    payload["description"] = description;

    APIClient::instance().post(
        "api/disputes/",
        payload,
        [this](bool success, 
        const QJsonObject& response)
        {
            if(success){
                Dispute* dispute = new Dispute(
                    response.value("id").toString(),
                    response.value("bookingId").toString(),
                    response.value("issue").toString(),
                    static_cast<DisputeStatus>(response.value("status").toInt()),
                    this
                );
                emit disputeRaised(dispute);
            }else{
                emit disputeError(response.value("error").toString());
            }
        });
}

// void DisputeRepositoryImpl::getDisputes()
// {
//     APIClient::instance().get(
//         "api/disputes/",
//         [this](bool success,
//         const QJsonObject& response)
//         {
//             QList<Dispute*> disputes;
//             if(success && response.contains("data")){
//                 QJsonArray dataArray = response["data"].toArray();
//                 for(const QJsonValue& value : dataArray){
//                     QJsonObject obj = value.toObject();
//                     Dispute* dispute = new Dispute(
//                         obj.value("id").toString(),
//                         obj.value("bookingId").toString(),
//                         obj.value("issue").toString(),
//                         static_cast<DisputeStatus>(obj.value("status").toInt()),
//                         this
//                     );
//                     disputes.append(dispute);
//                 }
            
//             }
            
//     });
//}

void DisputeRepositoryImpl::resolveDispute(const QString& disputeId)
{
    QJsonObject payload;

    APIClient::instance().patch(
        "api/disputes/:" + disputeId + "/resolve",
        payload,
        [this](bool success,
        const QJsonObject& response)
        {
            if(success){
                Dispute* dispute = new Dispute(
                    response.value("id").toString(),
                    response.value("bookingId").toString(),
                    response.value("issue").toString(),
                    static_cast<DisputeStatus>(response.value("status").toInt()),
                    this
                );
                emit disputeResolved(dispute);
            }else{
                emit disputeError(response.value("error").toString());
            }
        });
}


