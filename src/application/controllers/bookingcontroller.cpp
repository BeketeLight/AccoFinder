#include "bookingcontroller.h"

BookingController::BookingController(QObject *parent)
  : QObject{parent},
    m_bookingRepository(new BookingRepositoryImpl(this))
{
    auto stopLoading = [this](){ setLoading(false); };

    connect(m_bookingRepository, &BookingRepositoryImpl::bookingCreated, this, [this, stopLoading](Booking* b){
        stopLoading();
        emit bookingCreated(b);
    });
    connect(m_bookingRepository, &BookingRepositoryImpl::bookingLoaded, this, [this, stopLoading](Booking* b){
        stopLoading();
        emit bookingLoaded(b);
    });
    connect(m_bookingRepository, &BookingRepositoryImpl::bookingsLoaded, this, [this, stopLoading](const QList<Booking*>& l){
        stopLoading();
        emit bookingsLoaded(l);
    });
    connect(m_bookingRepository, &BookingRepositoryImpl::bookingCancelled, this, [this, stopLoading](Booking* b){
        stopLoading();
        emit bookingCancelled(b);
    });
    connect(m_bookingRepository, &BookingRepositoryImpl::bookingConfirmed, this, [this, stopLoading](Booking* b){
        stopLoading();
        emit bookingConfirmed(b);
    });
    connect(m_bookingRepository, &BookingRepositoryImpl::bookingDeleted, this, [this, stopLoading](const QString& id){
        stopLoading();
        emit bookingDeleted(id);
    });
    connect(m_bookingRepository, &BookingRepositoryImpl::bookingError, this, [this, stopLoading](const QString& err){
        stopLoading();
        emit bookingError(err);
    });
}

void BookingController::setLoading(bool loading)
{
    if (m_isLoading == loading) return;
    m_isLoading = loading;
    emit isLoadingChanged(m_isLoading);
}

void BookingController::createBooking(const QString& roomId,
                                      double amount,
                                      double commissionAmount)
{
    // Pull client id from AppSettings (single source of truth)
    const QString clientId = AppSettings::instance().userId();
    if (roomId.isEmpty()) {
        emit bookingError("House ID is required.");
        return;
    }

    if (clientId.isEmpty()) {
        emit bookingError("Invalid client Id");
        return;
    }

    if (!amount) {
        emit bookingError("Invalid amount");
        return;
    }

    if (!commissionAmount) {
        emit bookingError("Invalid commissionAmount");
        return;
    }

    setLoading(true);
    m_bookingRepository->createBooking(roomId, clientId, amount, commissionAmount);
}

void BookingController::fetchBookings()
{
    setLoading(true);
    m_bookingRepository->getBooking();
}

void BookingController::fetchBookingById(const QString &id)
{
    if(id.isEmpty()) return;
    setLoading(true);
    m_bookingRepository->getBookingById(id);
}

void BookingController::cancelBooking(const QString &id)
{
    if(id.isEmpty()) return;
    setLoading(true);
    m_bookingRepository->cancelBooking(id);
}

void BookingController::confirmBooking(const QString &id)
{
    if(id.isEmpty()) return;
    setLoading(true);
    m_bookingRepository->confirmBooking(id);
}

void BookingController::deleteBooking(const QString &id)
{
    if(id.isEmpty()) return;
    setLoading(true);
    m_bookingRepository->deleteBooking(id);
}
