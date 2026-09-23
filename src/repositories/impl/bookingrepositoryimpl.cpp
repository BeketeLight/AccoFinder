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
    const QString& roomId,
    const QString& clientId,
    double amount,
    double commissionAmount)
{
    QJsonObject payload;
    payload["roomId"] = roomId;
    payload["clientId"] = clientId;
    payload["amount"] = amount;
    payload["commissionAmount"]= commissionAmount;

    APIClient::instance().post(
        "/bookings/",
        payload,
        [this](bool success,
            const QJsonObject& response)
        {
            if (success) {
                // Backend wraps the resource in a "data" object
                const QJsonObject data = response.value("data").toObject();

                // Helper to read "_id" first, then "id"
                auto readId = [](const QJsonObject& obj) -> QString {
                    if (obj.contains("_id")) return obj.value("_id").toString();
                    return obj.value("id").toString();
                };

                // Booking id
                const QString bookingId = readId(data);

                // clientId may be a string OR an object with _id
                QString clientId;
                const QJsonValue clientVal = data.value("clientId");
                if (clientVal.isObject()) {
                    clientId = readId(clientVal.toObject());
                } else {
                    clientId = clientVal.toString();
                }

                // roomId may be a string OR an object with _id
                QString roomId;
                const QJsonValue roomVal = data.value("roomId");
                if (roomVal.isObject()) {
                    roomId = readId(roomVal.toObject());
                } else {
                    roomId = roomVal.toString();
                }

                Booking* booking = new Booking(
                    bookingId,
                    clientId,
                    roomId,
                    QDateTime::fromString(data.value("bookingDate").toString(), Qt::ISODate),
                    data.value("amount").toDouble(),
                    data.value("commissionAmount").toDouble(),
                    this
                    );

                qDebug() << "booking was successfully created, bookingId" << booking->getId();

                emit bookingCreated(booking);
            }
            else {
                QString message = response.value("message").toString();

                // Fall back to other keys if "message" is empty
                if (message.isEmpty())
                    message = response.value("error").toString();
                if (message.isEmpty())
                    message = response.value("detail").toString();
                if (message.isEmpty())
                    message = QStringLiteral("Could not create booking");
                emit bookingError(message);
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


