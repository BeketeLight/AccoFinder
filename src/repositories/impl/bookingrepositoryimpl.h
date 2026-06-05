#ifndef BOOKINGREPOSITORYIMPL_H
#define BOOKINGREPOSITORYIMPL_H

#include "repositories/interfaces/IBookingRepository.h"
#include "models/booking.h"


class BookingRepositoryImpl : public IBookingRepository
{

public:
    BookingRepositoryImpl();

    Booking* createBooking() override;
    Booking* getBooking() override;
    Booking* cancelBooking() override;
private:
    Booking* booking = new Booking;
};

#endif // BOOKINGREPOSITORYIMPL_H
