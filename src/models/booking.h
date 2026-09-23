#ifndef BOOKING_H
#define BOOKING_H

#include <QObject>
#include <QDateTime>
#include "core/utils/EBookingStatus.h"

class Booking : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ getId WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString clientId READ getClientId WRITE setClientId NOTIFY clientIdChanged)
    Q_PROPERTY(QString roomId READ getRoomId WRITE setRoomId NOTIFY roomIdChanged)
    Q_PROPERTY(QDateTime bookingDate READ getBookingDate WRITE setBookingDate NOTIFY bookingDateChanged)
    Q_PROPERTY(double amount READ getAmount WRITE setAmount NOTIFY amountChanged)
    Q_PROPERTY(double commissionAmount READ getCommissionAmount WRITE setCommissionAmount NOTIFY commissionAmountChanged)
public:
    explicit Booking(QObject *parent = nullptr);
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


    void setId(const QString &newId);

    void setClientId(const QString &newClientId);

    void setRoomId(const QString &newRoomId);

    void setBookingDate(const QDateTime &newBookingDate);

    void setAmount(double newAmount);

    void setCommissionAmount(double newCommissionAmount);

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

    // Property change notifications (required by Q_PROPERTY NOTIFY)
    void idChanged();
    void clientIdChanged();
    void roomIdChanged();
    void bookingDateChanged();
    void amountChanged();
    void commissionAmountChanged();
};

#endif // BOOKING_H
