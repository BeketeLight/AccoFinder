#ifndef BOOKINGREPOSITORYIMPL_H
#define BOOKINGREPOSITORYIMPL_H

#include "repositories/interfaces/IBookingRepository.h"
#include "models/booking.h"


class BookingRepositoryImpl : public IBookingRepository
{
    Q_OBJECT
public:
    explicit BookingRepositoryImpl(QObject *parent = nullptr);

    void createBooking(
        const QString& houseId,
        const QDateTime& startDate,
        const QDateTime& endDate,
        const QString& specialNotes
    ) override;
    void getBooking() override;
    // void cancelBooking(const QString& id) override;
    // void confirmBooking(const QString& id) override;
   void deleteBooking(const QString& id) override;
   void getBookingById(const QString& id) override;

signals:
    void bookingCreated(Booking* booking);
    void bookingLoaded(Booking* booking);
    void bookingsLoaded(const QList<Booking*>& bookings);
    //void bookingCancelled(Booking* booking);
    //void bookingConfirmed(Booking* booking);
    void bookingDeleted(const QString& id);
    void bookingError(const QString& error);
};

#endif // BOOKINGREPOSITORYIMPL_H
