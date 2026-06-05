#ifndef BOOKING_H
#define BOOKING_H

#include <QObject>
#include <QDateTime>
#include "core/utils/EBookingStatus.h"

class Booking : public QObject
{
    Q_OBJECT
public:
    explicit Booking(QObject *parent = nullptr);
    QString getId() const;
    void setId(const QString &newId);
    QString getClientId() const;
    void setClientId(const QString &newClientId);
    QString getRoomId() const;
    void setRoomId(const QString &newRoomId);
    QDateTime getBookingDate() const;
    void setBookingDate(const QDateTime &newBookingDate);
    BookingStatus getStatus() const;
    void setStatus(BookingStatus newStatus);
    double getAmount() const;
    void setAmount(double newAmount);
    double getCommissionAmount() const;
    void setCommissionAmount(double newCommissionAmount);

private:
    QString id;
    QString clientId;
    QString roomId;
    QDateTime bookingDate;
    BookingStatus status;
    double amount;
    double commissionAmount;
signals:
    void bookingConfirmed();
    void bookingCancelled();
};

#endif // BOOKING_H
