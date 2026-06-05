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
    virtual Booking* createBooking() = 0;
    virtual Booking* getBooking() = 0;
    virtual Booking* cancelBooking() = 0;

    virtual ~IBookingRepository() {}
private:

signals:

};



#endif // IBOOKINGREPOSITORY_H
