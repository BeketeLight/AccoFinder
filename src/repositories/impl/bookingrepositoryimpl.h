#ifndef BOOKINGREPOSITORYIMPL_H
#define BOOKINGREPOSITORYIMPL_H

#include <QSet>

#include "repositories/interfaces/IBookingRepository.h"
#include "models/booking.h"


class BookingRepositoryImpl : public IBookingRepository
{
    Q_OBJECT
public:
    explicit BookingRepositoryImpl(QObject *parent = nullptr);

    void createBooking(
        const QString& bookableItemId,
        const QString& clientId,
        double amount,
        double commissionAmount
    ) override;
    void getBooking() override;
    void cancelBooking(const QString& id) override;
    void confirmBooking(const QString& id) override;
    void releaseBooking(const QString& id) override;
    void deleteBooking(const QString& id) override;
    void getBookingById(const QString& id) override;

private:
    // Several screens load the same booking feed on first use. Only one GET per
    // URL should be in flight; pull-to-refresh still works once it completes.
    QSet<QString> m_inFlightUrls;

signals:
    void bookingCreated(Booking* booking);
    void bookingLoaded(Booking* booking);
    void bookingsLoaded(const QList<Booking*>& bookings);
    void bookingCancelled(Booking* booking);
    void bookingConfirmed(Booking* booking);
    void bookingReleased(Booking* booking);
    void bookingDeleted(const QString& id);
    void bookingError(const QString& error);
};

#endif // BOOKINGREPOSITORYIMPL_H
