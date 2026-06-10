#ifndef BOOKINGCONTROLLER_H
#define BOOKINGCONTROLLER_H


#include <QObject>
#include "models/booking.h"
#include "repositories/impl/bookingrepositoryimpl.h"

class BookingController : public QObject
{
    Q_OBJECT
public:
    explicit BookingController(QObject *parent = nullptr);
    Booking* createBooking();
    Booking* getBooking();
    Booking* cancelBooking();
};

#endif // BOOKINGCONTROLLER_H
