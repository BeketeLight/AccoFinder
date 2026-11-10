#include "paymentsoverviewviewmodel.h"
#include <QJsonArray>

PaymentsOverviewViewModel::PaymentsOverviewViewModel(QObject *parent)
    : QObject(parent),
      m_repository(new PaymentsOverviewRepositoryImpl(this)),
      m_gateway(new PaymentGatewayImpl(this)),
      m_payments(new PaymentsListModel(this)),
      m_commissions(new PaymentsListModel(this)),
      m_payouts(new PaymentsListModel(this))
{
    connect(m_repository, &PaymentsOverviewRepositoryImpl::overviewFetched,
            this, [this](const QJsonObject& data) {
        applyOverview(data);
        setLoading(false);
        emit overviewChanged();
    });

    connect(m_repository, &PaymentsOverviewRepositoryImpl::fetchError,
            this, [this](const QString& error) {
        setLoading(false);
        emit errorOccurred(error);
    });

    connect(m_gateway, &PaymentGatewayImpl::commissionSettled,
            this, [this](const QJsonObject& data) {
        setLoading(false);
        emit commissionSettled(data.toVariantMap());
        refresh();
    });
    connect(m_gateway, &PaymentGatewayImpl::payoutReleased,
            this, [this](const QJsonObject& data) {
        setLoading(false);
        emit payoutReleased(data.toVariantMap());
        refresh();
    });
    connect(m_gateway, &PaymentGatewayImpl::paymentError,
            this, [this](const QString& error) {
        setLoading(false);
        emit actionFailed(error);
    });
}

void PaymentsOverviewViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

QVector<QVariantMap> PaymentsOverviewViewModel::listFromJson(
    const QJsonObject& data, const QString& key)
{
    QVector<QVariantMap> rows;
    const QVariantList array = data.value(key).toArray().toVariantList();
    for (const QVariant& item : array) {
        rows.append(item.toMap());
    }
    return rows;
}

void PaymentsOverviewViewModel::applyOverview(const QJsonObject& data)
{
    m_totalCollected = data.value("totalCollected").toDouble();
    m_pendingCount = data.value("pendingCount").toInt();
    m_commissionsDue = data.value("commissionsDue").toDouble();
    m_payoutsPending = data.value("payoutsPending").toInt();

    m_payments->setRows(listFromJson(data, "payments"));
    m_commissions->setRows(listFromJson(data, "commissions"));
    m_payouts->setRows(listFromJson(data, "payouts"));
}

void PaymentsOverviewViewModel::refresh()
{
    setLoading(true);
    m_repository->fetchOverview();
}

void PaymentsOverviewViewModel::settleCommission(const QString& agentName,
                                                 const QString& paymentId,
                                                 const QString& bookingId,
                                                 const QString& agentId)
{
    if (agentName.isEmpty() && agentId.isEmpty()
        && paymentId.isEmpty() && bookingId.isEmpty()) {
        emit actionFailed("A commission row needs an agent or payment identifier.");
        return;
    }
    setLoading(true);
    m_gateway->settleCommission(paymentId, bookingId, agentId, agentName);
}

void PaymentsOverviewViewModel::releasePayout(const QString& landlord,
                                              const QString& paymentId,
                                              const QString& bookingId,
                                              const QString& landlordId)
{
    if (landlord.isEmpty() && landlordId.isEmpty()
        && paymentId.isEmpty() && bookingId.isEmpty()) {
        emit actionFailed("A payout row needs a landlord, booking, or payment identifier.");
        return;
    }
    setLoading(true);
    m_gateway->releasePayout(paymentId, bookingId, landlordId, landlord);
}