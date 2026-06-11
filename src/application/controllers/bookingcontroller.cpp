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

void BookingController::createBooking(const QString &houseId, const QDateTime &startDate, const QDateTime &endDate, const QString &specialNotes)
{
    if (houseId.isEmpty()) {
        emit bookingError("House ID is required.");
        return;
    }

    if (!startDate.isValid() || !endDate.isValid()) {
        emit bookingError("Invalid booking dates.");
        return;
    }

    if (startDate < QDateTime::currentDateTime()) {
        emit bookingError("Start date cannot be in the past.");
        return;
    }

    if (endDate <= startDate) {
        emit bookingError("End date must be after the start date.");
        return;
    }

    setLoading(true);
    m_bookingRepository->createBooking(houseId, startDate, endDate, specialNotes);
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
