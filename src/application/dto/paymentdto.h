#ifndef PAYMENTDTO_H
#define PAYMENTDTO_H


#include <QDateTime>
#include <QJsonObject>
#include "models/payment.h"
#include "core/utils/EPaymentStatus.h"

class PaymentDto
{
public:
    PaymentDto();

    PaymentDto(
        const QString& id,
        const QString& bookingId,
        double amount,
        const QString& method,
        const PaymentStatus& status,
        const QString& transactionRef,
        const QString& payoutStatus,
        const QDateTime& payoutDate
        );

    QString m_id;
    QString m_bookingId;
    double m_amount;
    QString m_method;
    PaymentStatus m_status;
    QString m_transactionRef;
    QString m_payoutStatus;
    QDateTime m_payoutDate;

    static PaymentDto fromJson(
        const QJsonObject& json);

    QJsonObject toJson() const;

    Payment* toDomainModel() const;
};

#endif // PAYMENTDTO_H
