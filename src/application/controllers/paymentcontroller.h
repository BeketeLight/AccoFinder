#ifndef PAYMENTCONTROLLER_H
#define PAYMENTCONTROLLER_H

#include <QObject>
#include <QString>
#include <QList>
#include <QVariantList>
#include "services/paymentgatewayimpl.h"
#include "models/payment.h"
#include "presentation/models/paymentslistmodel.h"

class PaymentController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(PaymentsListModel* paymentListModel READ paymentListModel CONSTANT)
    Q_PROPERTY(int paymentCount READ paymentCount NOTIFY paymentCountChanged)
public:
    explicit PaymentController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }
    PaymentsListModel* paymentListModel() const { return m_listModel; }

    // ---------------- PAYMENT OPERATIONS ----------------

    /**
     * Initiates a payment transaction.
     * - Validates payment input (amount, method, user, etc.)
     * - Calls PaymentGatewayRepositoryImpl::processPayment()
     * - Returns the created Payment object
     */
    Q_INVOKABLE void createPayment(const QString& bookingId,
                                   double amount,
                                   const QString& method,
                                   const QString& operatorRefId = QString(),
                                   const QString& phoneNumber = QString());

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

    // ---- New: refresh list for a user and for a booking ----
    // Backend: GET /payments/user/:userId  (returns most recent payment)
    // The app fetches one at a time; we accumulate into the list model.
    Q_INVOKABLE void refreshForUser(const QString& userId);
    Q_INVOKABLE void refreshForBooking(const QString& bookingId);

    Q_INVOKABLE void fetchOperators();
    Q_INVOKABLE void verifyPayment(const QString& chargeId);

    // ---- C++-only helper for the gateway to append a payment ----
    void appendPaymentToList(Payment* payment);
    void clearList();
    int paymentCount() const { return m_listModel ? m_listModel->size() : 0; }

signals:
    void paymentCreated(Payment* payment);
    void paymentLoaded(Payment* payment);
    void paymentsLoaded(const QList<Payment*>& payments);
    void paymentRefunded(Payment* payment);
    void paymentError(const QString& error);
    void isLoadingChanged(bool isLoading);
    void paymentCountChanged(int count);
    void operatorsLoaded(const QVariantList& operators);
    void operatorsError(const QString& error);
    void paymentVerified(Payment* payment);
    void paymentVerificationPending(Payment* payment);

private:
    void setLoading(bool loading);
    PaymentGatewayImpl* m_paymentRepo;
    PaymentsListModel* m_listModel = nullptr;
    bool m_isLoading = false;
    QVariantList m_operatorsCache;
};

#endif 
