#include "bookingviewmodel.h"

BookingViewModel::BookingViewModel(QObject *parent)
    : QObject(parent),
    m_bookingController(new BookingController (this)),
    m_bookingListModel(new BookingListModel (this))
{
     connect(m_bookingController.data(), &BookingController::bookingCreated,
        this,&BookingViewModel::onBookingCreated);
    
    // connect(m_bookingController, &BookingController::bookingsLoaded,
    //      this,&BookingViewModel::onBookingsLoaded);
    connect(m_bookingController.data(), &BookingController::bookingsLoaded,
        this,&BookingViewModel::onBookingsLoaded);
    connect(m_bookingController.data(), &BookingController::bookingLoaded,
        this,&BookingViewModel::onBookingLoaded);
    connect(m_bookingController.data(), &BookingController::bookingCancelled,
        this,&BookingViewModel::onBookingCancelled);  
    connect(m_bookingController.data(), &BookingController::bookingConfirmed,
        this,&BookingViewModel::onBookingConfirmed); 
    connect(m_bookingController.data(), &BookingController::bookingDeleted,
        this,&BookingViewModel::onBookingDeleted);   
    connect(m_bookingController.data(), &BookingController::isLoadingChanged,
        this,&BookingViewModel::isLoadingChanged);
    connect(m_bookingController.data(), &BookingController::bookingError,
        this,&BookingViewModel::onBookingError);                    
}
void BookingViewModel::createBooking(const QString& houseId,
                             const QDateTime& startDate,
                             const QDateTime& endDate,
                             const QString& specialNotes)
{   
    if(m_bookingController)
    m_bookingController->createBooking(houseId,startDate,endDate,specialNotes);
    
}

void BookingViewModel::fetchBookings()
{
    if(m_bookingController)
    m_bookingController->fetchBookings();
} 

void BookingViewModel::fetchBookingById(const QString& id)
{
    if(m_bookingController)
    m_bookingController->fetchBookingById(id);
}
void BookingViewModel::cancelBooking(const QString& id)
{   
    if(m_bookingController)
    m_bookingController->cancelBooking(id);
}
void BookingViewModel::confirmBooking(const QString& id)
{   
    if(m_bookingController)
    m_bookingController->confirmBooking(id);
}
void BookingViewModel::deleteBooking(const QString& id)
{   
    if(m_bookingController)
    m_bookingController->deleteBooking(id);
}

void BookingViewModel::onBookingLoaded(Booking* booking)
{   
    if(m_bookingListModel)
    m_bookingListModel->addBooking(booking);
}
void BookingViewModel::onBookingsLoaded(const QList<Booking*>& bookings)
{
    if (!m_bookingListModel)
        return;
    m_bookingListModel->clear();
    for (Booking* b : bookings)
        m_bookingListModel->addBooking(b);
}
void BookingViewModel::onBookingCreated(Booking* booking)
{   
    if(m_bookingListModel)
    m_bookingListModel->addBooking(booking);
}
void BookingViewModel::onBookingConfirmed(Booking* booking)
{
    if(m_bookingListModel)
    m_bookingListModel->addBooking(booking);
}
void BookingViewModel::onBookingCancelled(Booking* booking)
{   
    if(m_bookingListModel)
    m_bookingListModel->removeBooking(m_index);
}
void BookingViewModel::onBookingDeleted(const QString& id)
{   
    if(m_bookingListModel)
    m_bookingListModel->removeBooking(m_index);
}
bool BookingViewModel::isLoading() const
{
    if(m_bookingController)
    return m_bookingController->isLoading();

    return false;
}

void BookingViewModel::onBookingError(const QString& error)
{
    emit errorOccurred(error);
}

int BookingViewModel::pendingBookingsCount() const
{
    return m_bookingListModel ? m_bookingListModel->countByStatus(BookingStatus::Pending) : 0;
}

int BookingViewModel::confirmedBookingsCount() const
{
    if (!m_bookingListModel)
        return 0;
    return m_bookingListModel->countByStatus(BookingStatus::Confirmed)
         + m_bookingListModel->countByStatus(BookingStatus::Paid);
}

int BookingViewModel::cancelledBookingsCount() const
{
    return m_bookingListModel ? m_bookingListModel->countByStatus(BookingStatus::Cancelled) : 0;
}

double BookingViewModel::totalBookingValue() const
{
    return m_bookingListModel ? m_bookingListModel->sumAmount() : 0.0;
}

double BookingViewModel::commissionEarned() const
{
    return m_bookingListModel ? m_bookingListModel->sumCommission() : 0.0;
}
