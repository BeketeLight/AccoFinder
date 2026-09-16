#ifndef IBOOKINGREPOSITORY_H
#define IBOOKINGREPOSITORY_H

#include <QObject>
#include "models/booking.h"

class IBookingRepository : public QObject
{
    Q_OBJECT
public:
    explicit IBookingRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    virtual void createBooking(
        const QString& roomId,
        const QString& clientId,
        double amount,
        double commissionAmount) = 0;

    virtual void getBooking() = 0;
    virtual void getBookingById(const QString& id) = 0;
    virtual void cancelBooking(const QString& id) = 0;
    virtual void confirmBooking(const QString& id) = 0;
    virtual void deleteBooking(const QString& id) = 0;

    virtual ~IBookingRepository() {}
};



#endif // IBOOKINGREPOSITORY_H
