#include "paymentcontroller.h"
#include <QUuid>

PaymentController::PaymentController(QObject *parent)
    : QObject(parent),
      m_paymentRepo(new PaymentGatewayImpl())
{
    // Connect repository signals to controller signals
    connect(m_paymentRepo, &PaymentGatewayImpl::paymentCreated, this, [this](Payment* payment) {
        setLoading(false);
        emit paymentCreated(payment);
    });

    connect(m_paymentRepo, &PaymentGatewayImpl::paymentLoaded, this, [this](Payment* payment) {
        setLoading(false);
        emit paymentLoaded(payment);
    });

    connect(m_paymentRepo, &PaymentGatewayImpl::paymentCancelled, this, [this](Payment* payment) {
        setLoading(false);
        emit paymentRefunded(payment);
    });

    connect(m_paymentRepo, &PaymentGatewayImpl::paymentError, this, [this](const QString& error) {
        setLoading(false);
        emit paymentError(error);
    });
}

void PaymentController::createPayment(const QString &bookingId, double amount, const QString &method)
{
    if (bookingId.isEmpty() || amount <= 0) {
        emit paymentError("Invalid booking ID or amount.");
        return;
    }

    setLoading(true);
    QString paymentId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    
    // Initiating payment through the gateway
    m_paymentRepo->createPayment(
        paymentId,
        bookingId,
        amount,
        method,
        PaymentStatus::Initiated,
        "", // transactionRef
        "", // payoutStatus
        QDateTime() // payoutDate
    );
}

void PaymentController::getPaymentById(const QString &id)
{
    if (id.isEmpty()) {
        emit paymentError("Payment ID is required.");
        return;
    }
    setLoading(true);
    m_paymentRepo->getPaymentById(id);
}

void PaymentController::refundPayment(Payment *payment)
{
    if (!payment) {
        emit paymentError("Payment object is required for refund.");
        return;
    }
    setLoading(true);
    
    // Mapping refund to cancelPayment in repository using existing payment data
    m_paymentRepo->cancelPayment(
        payment->getId(),
        payment->getBookingId(),
        payment->getAmount(),
        payment->getMethod(),
        PaymentStatus::Failed,
        payment->getTransactionalRef(),
        payment->getPayoutStatus(),
        payment->getPayoutDate()
    );
}

void PaymentController::getAllPayments()
{
    // The repository currently does not provide a method to get all payments.
    // Signaling an error for now as it's not implemented in the service layer.
    emit paymentError("GetAllPayments functionality is not yet available in the gateway.");
}

void PaymentController::getPaymentStatus(const QString &id)
{
    if (id.isEmpty()) return;
    setLoading(true);
    
    // Refreshing payment data to get current status
    m_paymentRepo->getPaymentById(id);
}

void PaymentController::refreshForUser(const QString& userId)
{
    if (userId.isEmpty()) {
        emit paymentError("User ID is required.");
        return;
    }
    setLoading(true);
    m_paymentRepo->getPaymentById(userId);
}

void PaymentController::refreshForBooking(const QString& bookingId)
{
    if (bookingId.isEmpty()) {
        emit paymentError("Booking ID is required.");
        return;
    }
    setLoading(true);
    m_paymentRepo->getPaymentById(bookingId);
}

void PaymentController::appendPaymentToList(Payment* payment)
{
    if (!payment) return;

    QVariantMap row;
    row["paymentId"]     = payment->getId();
    row["id"]            = payment->getId();
    row["bookingId"]     = payment->getBookingId();
    row["amount"]        = payment->getAmount();
    row["method"]        = payment->getMethod();
    row["status"]        = payment->statusInt();
    row["statusText"]    = QString::number(payment->statusInt());
    row["transactionRef"] = payment->getTransactionalRef();
    row["payoutStatus"]  = payment->getPayoutStatus();
    row["payoutDate"]    = payment->getPayoutDate();
    row["paidAt"]        = payment->getPaidAt();

    // Deduplicate by paymentId: replace if present, append otherwise
    QVector<QVariantMap> rows;
    bool replaced = false;
    for (int i = 0; i < m_listModel->size(); i++) {
        QVariantMap existing = m_listModel->at(i);
        if (existing.value("paymentId").toString() == payment->getId()) {
            rows.append(row);
            replaced = true;
        } else {
            rows.append(existing);
        }
    }
    if (!replaced)
        rows.append(row);

    m_listModel->setRows(rows);
    emit paymentCountChanged(m_listModel->size());
}

void PaymentController::clearList()
{
    m_listModel->clear();
    emit paymentCountChanged(0);
}

void PaymentController::setLoading(bool loading)
{
    if (m_isLoading == loading) return;
    m_isLoading = loading;
    emit isLoadingChanged(m_isLoading);
}
