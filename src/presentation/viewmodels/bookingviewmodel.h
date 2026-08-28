#ifndef BOOKINGVIEWMODEL_H
#define BOOKINGVIEWMODEL_H

#include <QObject>
#include <QSharedPointer>
#include "application/controllers/bookingcontroller.h"
#include "presentation/models/bookinglistmodel.h"

class BookingViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(BookingListModel *bookingListModel READ bookingListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    bool isLoading() const;
    explicit BookingViewModel(QObject *parent = nullptr);

    BookingListModel *bookingListModel() const { return m_bookingListModel.data(); }

    Q_INVOKABLE void createBooking(const QString& houseId,
                             const QDateTime& startDate,
                             const QDateTime& endDate,
                             const QString& specialNotes);

    Q_INVOKABLE void fetchBookings();
    Q_INVOKABLE void fetchBookingById(const QString& id);
    Q_INVOKABLE void cancelBooking(const QString& id);
    Q_INVOKABLE void confirmBooking(const QString& id);
    Q_INVOKABLE void deleteBooking(const QString& id);

    Q_INVOKABLE int pendingBookingsCount() const;
    Q_INVOKABLE int confirmedBookingsCount() const;
    Q_INVOKABLE int cancelledBookingsCount() const;
    Q_INVOKABLE double totalBookingValue() const;
    Q_INVOKABLE double commissionEarned() const;

private slots:
        // void onBookingsLoaded(const QList<Booking*>& bookings);
        void onBookingsLoaded(const QList<Booking*>& bookings);
        void onBookingCreated(Booking* booking);
        void onBookingLoaded(Booking* booking);
        void onBookingConfirmed(Booking* booking);
        void onBookingCancelled(Booking* booking);
        void onBookingDeleted(const QString& id);
        void onBookingError(const QString& error);
signals:
    void isLoadingChanged(bool isLoading);
    void errorOccurred(const QString& error);
            
private:
    int m_index;
    QSharedPointer<BookingController> m_bookingController;
    QSharedPointer<BookingListModel> m_bookingListModel;        
    
};

#endif // BOOKINGVIEWMODEL_H

