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
    Q_PROPERTY(QString clientName READ getClientName WRITE setClientName NOTIFY clientNameChanged)/// to extract client details
    Q_PROPERTY(QString clientPhone READ getClientPhone WRITE setClientPhone NOTIFY clientPhoneChanged)
    Q_PROPERTY(QString clientEmail READ getClientEmail WRITE setClientEmail NOTIFY clientEmailChanged)

    // When the provisional hold on this booking lapses. Invalid (and
    // holdSecondsRemaining == 0) for bookings that are not on a hold, which is
    // how the UI decides whether to show a countdown at all.
    Q_PROPERTY(QDateTime holdExpiresAt READ getHoldExpiresAt WRITE setHoldExpiresAt NOTIFY holdExpiresAtChanged)
    Q_PROPERTY(int holdSecondsRemaining READ getHoldSecondsRemaining NOTIFY holdSecondsRemainingChanged)
    Q_PROPERTY(bool holdActive READ getHoldActive NOTIFY holdActiveChanged)

    // Status as a display string. The enum itself is deliberately not exposed
    // to QML: BookingStatus is a plain enum class with no metatype/Q_ENUM
    // registration, so a Q_PROPERTY of that type would not be usable from QML.
    Q_PROPERTY(QString status READ getStatusString NOTIFY statusChanged)
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
    QString getStatusString() const;
    QDateTime getHoldExpiresAt() const;
    void setHoldExpiresAt(const QDateTime& newHoldExpiresAt);
    int getHoldSecondsRemaining() const;
    bool getHoldActive() const;
    // Recomputes holdSecondsRemaining / holdActive. Called on a timer by the
    // views that render a countdown.
    void refreshHoldCountdown();
    double getAmount() const;
    double getCommissionAmount() const;
    QString getClientName() const;//
    QString getClientPhone() const;//
    QString getClientEmail() const;//
    void setClientName(const QString &newClientName);//
    void setClientPhone(const QString &newClientPhone);//
    void setClientEmail(const QString &newClientEmail);//

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
    QString m_clientName;//
    QString m_clientPhone;//
    QString m_clientEmail;//
    QDateTime m_holdExpiresAt;
    int m_holdSecondsRemaining = 0;
signals:
    void bookingCreated();
    void bookingConfirmed();
    void bookingCancelled();
    void bookingFeePaid();
    void bookingExpired();

    // Property change notifications (required by Q_PROPERTY NOTIFY)
    void idChanged();
    void clientIdChanged();
    void roomIdChanged();
    void bookingDateChanged();
    void amountChanged();
    void commissionAmountChanged();
    //Client details change notification
    void clientNameChanged();
    void clientPhoneChanged();
    void clientEmailChanged();
    void statusChanged();
    void holdExpiresAtChanged();
    void holdSecondsRemainingChanged();
    void holdActiveChanged();
};

#endif // BOOKING_H
