#ifndef BOOKING_H
#define BOOKING_H

#include <QObject>
#include <QDateTime>
#include "core/utils/EBookingStatus.h"

class Booking : public QObject
{
    Q_OBJECT
public:
    explicit Booking(const QString& id,
            const QString& clientId,
            const QString& roomId,
            const QDateTime& bookingDate,
            const double& amount,
            const double& commissionAmount,
            QObject *parent = nullptr);
    QString getId() const;
    QString getClientId() const;
    QString getRoomId() const;
    QDateTime getBookingDate() const;
    BookingStatus getStatus() const;
    void setStatus(const BookingStatus& status);
    double getAmount() const;
    double getCommissionAmount() const;


private:
    QString m_id;
    QString m_clientId;
    QString m_roomId;
    QDateTime m_bookingDate;
    BookingStatus m_status;
    double m_amount;
    double m_commissionAmount;
signals:
    void bookingCreated();
    void bookingConfirmed();
    void bookingCancelled();
    void bookingFeePaid();
};

#endif // BOOKING_H
