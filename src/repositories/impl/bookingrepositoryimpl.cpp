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
        "/bookings/",
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
    }, false);

}


void BookingRepositoryImpl::getBooking()
{
    APIClient::instance().get(
        "/bookings/",
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
        }, false);
}

void BookingRepositoryImpl::getBookingById(const QString& id)
{
    APIClient::instance().get(
        "/bookings/" + id,
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
     }, false);
}

void BookingRepositoryImpl::cancelBooking(const QString& id)
{
    QJsonObject payload;
    payload["id"] = id;

    APIClient::instance().patch(
        "/bookings/" + id + "/cancel",
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
           
    }, false);
}

void BookingRepositoryImpl::deleteBooking(const QString& id)
{
    APIClient::instance().del(
        "/bookings/" + id,
        [this,id] (bool success, const QJsonObject& response)
        {
            if(success){
                emit bookingDeleted(id);
            }else
            {
                emit bookingError(response["error"].toString());
            }   
    }, false);
}

void BookingRepositoryImpl::confirmBooking(const QString& id)
{
    QJsonObject payload;
    payload["id"] = id;

    APIClient::instance().patch(
        "/bookings/" + id + "/confirm",
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
           
        }, false);
}


