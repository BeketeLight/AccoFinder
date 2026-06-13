#ifndef PAYMENTCONTROLLER_H
#define PAYMENTCONTROLLER_H

#include <QObject>
#include <QString>
#include <QList>
#include "services/paymentgatewayimpl.h"
#include "models/payment.h"

class PaymentController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit PaymentController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }

    // ---------------- PAYMENT OPERATIONS ----------------

    /**
     * Initiates a payment transaction.
     * - Validates payment input (amount, method, user, etc.)
     * - Calls PaymentGatewayRepositoryImpl::processPayment()
     * - Returns the created Payment object
     */
    Q_INVOKABLE void createPayment(const QString& bookingId, double amount, const QString& method);

    /**
     * Retrieves a payment by its unique ID.
     * - Queries repository or service layer
     * - Returns Payment domain model if found
     */
    Q_INVOKABLE void getPaymentById(const QString& id);

    /**
     * Cancels or refunds a payment.
     * - Validates refund eligibility
     * - Calls PaymentGatewayRepositoryImpl::refundPayment()
     * - Returns updated Payment object
     */
    Q_INVOKABLE void refundPayment(Payment* payment);

    /**
     * Retrieves all payments for a specific user/account.
     * - Calls repository layer
     * - Returns list of Payment objects
     */
    Q_INVOKABLE void getAllPayments();

    /**
     * Checks payment status (pending, success, failed).
     * - Used by UI or background sync
     */
    Q_INVOKABLE void getPaymentStatus(const QString& id);

signals:
    void paymentCreated(Payment* payment);
    void paymentLoaded(Payment* payment);
    void paymentsLoaded(const QList<Payment*>& payments);
    void paymentRefunded(Payment* payment);
    void paymentError(const QString& error);
    void isLoadingChanged(bool isLoading);

private:
    void setLoading(bool loading);
    PaymentGatewayImpl* m_paymentRepo;
    bool m_isLoading = false;
};

#endif 
