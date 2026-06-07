#ifndef BOOKINGREPOSITORYIMPL_H
#define BOOKINGREPOSITORYIMPL_H

#include "repositories/interfaces/IBookingRepository.h"
#include "models/booking.h"


class BookingRepositoryImpl : public IBookingRepository
{
    Q_OBJECT
public:
    BookingRepositoryImpl();

    Booking* createBooking() override;
    Booking* getBooking() override;
    Booking* cancelBooking() override;
private:
};

#endif // BOOKINGREPOSITORYIMPL_H
