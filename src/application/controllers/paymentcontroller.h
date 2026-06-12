#ifndef PAYMENTCONTROLLER_H
#define PAYMENTCONTROLLER_H

#include "services/paymentgatewayimpl.h"
#include "models/payment.h"

class PaymentController
{
public:
    PaymentController();

    // ---------------- PAYMENT OPERATIONS ----------------

    /**
     * Initiates a payment transaction.
     * - Validates payment input (amount, method, user, etc.)
     * - Calls PaymentGatewayRepositoryImpl::processPayment()
     * - Returns the created Payment object
     */
    Payment* createPayment();

    /**
     * Retrieves a payment by its unique ID.
     * - Queries repository or service layer
     * - Returns Payment domain model if found
     */
    Payment* getPaymentById(const QString& id);

    /**
     * Cancels or refunds a payment.
     * - Validates refund eligibility
     * - Calls PaymentGatewayRepositoryImpl::refundPayment()
     * - Returns updated Payment object
     */
    Payment* refundPayment();

    /**
     * Retrieves all payments for a specific user/account.
     * - Calls repository layer
     * - Returns list of Payment objects
     */
    QList<Payment*> getAllPayments();

    /**
     * Checks payment status (pending, success, failed).
     * - Used by UI or background sync
     */
    QString getPaymentStatus(const QString& id);

private:
    PaymentGatewayImpl* m_paymentRepo;
};

#endif // PAYMENTCONTROLLER_H
