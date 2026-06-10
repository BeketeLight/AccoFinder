#include "bookingrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonValue>
#include <QList>
#include <QJsonArray>
#include <QDateTime>
#include "core/utils/appsettings.h"  //for persistence
#include "services/apiclient.h"

BookingRepositoryImpl::BookingRepositoryImpl(QObject *parent)
    : IBookingRepository(parent)
{

}
//===HELPER FUNCTION FOR STATUS===//


void BookingRepositoryImpl::createBooking(
    const QString& houseId,
    const QDateTime& startDate,
    const QDateTime& endDate,
    const QString& specialNotes )
{
    QJsonObject payload;
    payload["houseId"] = houseId;
    payload["startDate"] = startDate.toString(Qt::ISODate);
    payload["endDate"] = endDate.toString(Qt::ISODate);
    if(!specialNotes.isEmpty()){
        payload["specialNotes"] = specialNotes;
    }

    APIClient::instance().post(
        "api/house-booking/",
        payload,
        [this](bool success,
            const QJsonObject& response)
        {
            if(success){
                Booking* booking = new Booking(
                    response["id"].toString(),
                    response["clientId"].toString(),
                    response["roomId"].toString(),
                    QDateTime::fromString(response["bookingDate"].toString(), Qt::ISODate),
                    response["amount"].toDouble(),
                    response["commissionAmount"].toDouble(),
                    this
                );
                emit bookingCreated(booking);
            }
    });

}


void BookingRepositoryImpl::getBooking()
{
    APIClient::instance().get(
        "api/house-booking/",
        [this] (bool success, 
            const QJsonObject& response)
           {
             QList<Booking*> bookings;
            if(success && response.contains("data")){
                QJsonArray dataArray = response["data"].toArray();
                for(const QJsonValue& value : dataArray){
                    QJsonObject obj = value.toObject();
                    Booking* booking = new Booking(
                        obj["id"].toString(),
                        obj["clientId"].toString(),
                        obj["roomId"].toString(),
                        QDateTime::fromString(obj["bookingDate"].toString(), Qt::ISODate),
                        obj["amount"].toDouble(),
                        obj["commissionAmount"].toDouble(),
                        this
                    );  
                    bookings.append(booking);
                } 
            }
            emit bookingsLoaded(bookings);
        });
}

void BookingRepositoryImpl::getBookingById(const QString& id)
{
    APIClient::instance().get(
        "api/house-booking/:" + id,
        [this] (bool success, const QJsonObject& response)
        {
        if(success){
            Booking* booking = new Booking(
            response["id"].toString(),
            response["clientId"].toString(),
            response["roomId"].toString(),
            QDateTime::fromString(response["bookingDate"].toString(), Qt::ISODate),
            response["amount"].toDouble(),
            response["commissionAmount"].toDouble(),
            this
            );
             emit bookingLoaded(booking);
            }else
            {
                emit bookingError(response["error"].toString());
            }
     });
}

void BookingRepositoryImpl::cancelBooking(const QString& id)
{
    QJsonObject payload;
    payload["id"] = id;

    APIClient::instance().patch(
        "api/house-booking/cancel/:" + id + "/cancel",
        payload,
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                Booking* booking = new Booking(
                    response["id"].toString(),
                    response["clientId"].toString(),
                    response["roomId"].toString(),
                    QDateTime::fromString(response["bookingDate"].toString(), Qt::ISODate),
                    response["amount"].toDouble(),
                    response["commissionAmount"].toDouble(),
                    this
                );
               emit bookingCancelled(booking); 
            } else{
                emit bookingError(response["error"].toString());
            }   
           
    });
}

void BookingRepositoryImpl::deleteBooking(const QString& id)
{
    APIClient::instance().del(
        "api/house-booking/:" + id,
        [this,id] (bool success, const QJsonObject& response)
        {
            if(success){
                emit bookingDeleted(id);
            }else
            {
                emit bookingError(response["error"].toString());
            }   
    });
}

void BookingRepositoryImpl::confirmBooking(const QString& id)
{
    QJsonObject payload;
    payload["id"] = id;

    APIClient::instance().patch(
        "api/house-booking/:" + id + "/confirm",
        payload,
        [this] (bool success, const QJsonObject& response)
        {   
            Booking* booking = nullptr;
            if(success){
                if(response.contains("id")){
                Booking* booking = new Booking(
                    response["id"].toString(),
                    response["clientId"].toString(),
                    response["roomId"].toString(),
                    QDateTime::fromString(response["bookingDate"].toString(), Qt::ISODate),
                    response["amount"].toDouble(),
                    response["commissionAmount"].toDouble(),
                    this
                );
              }
               emit bookingConfirmed(booking ? booking : nullptr);
            }else{
                emit bookingError(response["error"].toString());
            }
           
        });
}


