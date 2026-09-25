#include "bookingrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonValue>
#include <QList>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDateTime>
#include "core/utils/appsettings.h"  //for persistence
#include "services/apiclient.h"

// ... other includes

// ---- helper (file scope) ----
static QString jsonId(const QJsonValue &v)
{
    if (v.isString())
        return v.toString();

    if (v.isObject()) {
        const QJsonObject o = v.toObject();
        if (o.contains(QStringLiteral("id")))
            return o.value(QStringLiteral("id")).toString();
        if (o.contains(QStringLiteral("_id")))
            return o.value(QStringLiteral("_id")).toString();
        if (o.contains(QStringLiteral("$oid")))
            return o.value(QStringLiteral("$oid")).toString();
    }

    // sometimes APIs send id as a number
    if (v.isDouble())
        return QString::number(v.toVariant().toLongLong());

    return {};
}
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
        QStringLiteral("/bookings/"),
        [this](bool success, const QJsonObject &response) {
            QList<Booking *> bookings;

            if (success && response.contains(QStringLiteral("data"))) {
                const QJsonArray dataArray = response.value(QStringLiteral("data")).toArray();
                for (const QJsonValue &value : dataArray) {
                    const QJsonObject obj = value.toObject();

                    const QString id = jsonId(obj.value(QStringLiteral("id")));
                    const QString idFallback =
                        id.isEmpty() ? jsonId(obj.value(QStringLiteral("_id"))) : id;

                    // ----- clientId: string OR populated user object -----
                    const QJsonValue clientVal = obj.value(QStringLiteral("clientId"));
                    QString clientId;
                    QString clientName = QStringLiteral("Client");
                    QString clientPhone;
                    QString clientEmail;

                    if (clientVal.isObject()) {
                        const QJsonObject c = clientVal.toObject();
                        clientId = jsonId(c);
                        const QString first = c.value(QStringLiteral("firstName")).toString();
                        const QString last  = c.value(QStringLiteral("lastName")).toString();
                        clientName = (first + QLatin1Char(' ') + last).trimmed();
                        if (clientName.isEmpty())
                            clientName = QStringLiteral("Client");
                        clientPhone = c.value(QStringLiteral("phone")).toString();
                        clientEmail = c.value(QStringLiteral("email")).toString();
                    } else {
                        clientId = jsonId(clientVal);
                    }

                    // ----- roomId: string OR populated room object -----
                    const QString roomId = jsonId(obj.value(QStringLiteral("roomId")));

                    qDebug() << "Parsed booking" << idFallback
                             << "clientId" << clientId
                             << "clientName" << clientName
                             << "roomId" << roomId;

                    auto *booking = new Booking(
                        idFallback,
                        clientId,
                        roomId,
                        QDateTime::fromString(
                            obj.value(QStringLiteral("bookingDate")).toString(),
                            Qt::ISODate),
                        obj.value(QStringLiteral("amount")).toDouble(),
                        obj.value(QStringLiteral("commissionAmount")).toDouble(),
                        this);

                    booking->setClientName(clientName);
                    booking->setClientPhone(clientPhone);
                    booking->setClientEmail(clientEmail);

                    // optional: status
                    // booking->setStatusFromString(obj.value(QStringLiteral("status")).toString());

                    qDebug() << "Booking object"
                             << "id" << booking->getId()
                             << "clientName" << booking->getClientName()
                             << "clientPhone" << booking->getClientPhone();

                    bookings.append(booking);
                }
            }

            emit bookingsLoaded(bookings);
        },
        false);
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



