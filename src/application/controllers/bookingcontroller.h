#ifndef BOOKINGCONTROLLER_H
#define BOOKINGCONTROLLER_H


#include <QObject>
#include <QString>
#include <QDateTime>
#include <QList>
#include "models/booking.h"
#include "repositories/impl/bookingrepositoryimpl.h"

class BookingController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit BookingController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void createBooking(const QString& houseId,
                                  const QDateTime& startDate,
                                  const QDateTime& endDate,
                                  const QString& specialNotes);
    Q_INVOKABLE void fetchBookings();
    Q_INVOKABLE void fetchBookingById(const QString& id);
    Q_INVOKABLE void cancelBooking(const QString& id);
    Q_INVOKABLE void confirmBooking(const QString& id);
    Q_INVOKABLE void deleteBooking(const QString& id);

signals:
    void bookingCreated(Booking* booking);
    void bookingLoaded(Booking* booking);
    void bookingsLoaded(const QList<Booking*>& bookings);
    void bookingCancelled(Booking* booking);
    void bookingConfirmed(Booking* booking);
    void bookingDeleted(const QString& id);
    void bookingError(const QString& error);
    void isLoadingChanged(bool isLoading);

private:
    void setLoading(bool loading);
    BookingRepositoryImpl* m_bookingRepository;
    bool m_isLoading = false;
};

#endif 
