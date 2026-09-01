#include "paymentsoverviewviewmodel.h"
#include <QJsonArray>

PaymentsOverviewViewModel::PaymentsOverviewViewModel(QObject *parent)
    : QObject(parent),
      m_repository(new PaymentsOverviewRepositoryImpl(this)),
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