#ifndef PAYMENT_H
#define PAYMENT_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include "core/utils/EPaymentStatus.h"

class Payment : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ getId NOTIFY idChanged)
    Q_PROPERTY(QString bookingId READ getBookingId NOTIFY bookingIdChanged)
    Q_PROPERTY(double amount READ getAmount NOTIFY amountChanged)
    Q_PROPERTY(QString method READ getMethod NOTIFY methodChanged)
    Q_PROPERTY(int status READ statusInt NOTIFY statusChanged)
    Q_PROPERTY(QString transactionRef READ getTransactionalRef NOTIFY transactionRefChanged)
    Q_PROPERTY(QString payoutStatus READ getPayoutStatus NOTIFY payoutStatusChanged)
    Q_PROPERTY(QDateTime payoutDate READ getPayoutDate NOTIFY payoutDateChanged)
    Q_PROPERTY(QDateTime paidAt READ getPaidAt NOTIFY paidAtChanged)
public:
    explicit Payment(QObject *parent = nullptr);

    int statusInt() const { return static_cast<int>(m_status); }
    Payment(const QString& id,
            const QString& bookingId,
            double amount,
            const QString& method,
            PaymentStatus status,
            const QString& transactionRef = "",
            const QString& payoutStatus = "",
            const QDateTime& payoutDate = QDateTime(),
            const QDateTime& paidAt = QDateTime(),
            QObject* parent = nullptr);
    QString getId() const;

    QString getBookingId() const;

    double getAmount() const;
    QString getMethod() const;
    PaymentStatus getStatus() const;
    void setStatus(PaymentStatus status);
    QString getTransactionalRef() const;
    QString getPayoutStatus() const;
    QDateTime getPayoutDate() const;
    QDateTime getPaidAt() const;
private:
    QString m_id;
    QString m_bookingId;
    double m_amount;
    QString m_method;
    PaymentStatus m_status;
    QString m_transactionalRef;
    QString m_payoutStatus;
    QDateTime m_payoutDate;
    QDateTime m_paidAt;

signals:
    void paymentProcessed();
    void paymentFailed();
    void paymentCreated();

    void idChanged();
    void bookingIdChanged();
    void amountChanged();
    void methodChanged();
    void statusChanged();
    void transactionRefChanged();
    void payoutStatusChanged();
    void payoutDateChanged();
    void paidAtChanged();


};

#endif // PAYMENT_H
