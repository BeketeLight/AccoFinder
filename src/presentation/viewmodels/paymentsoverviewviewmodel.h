#ifndef PAYMENTSOVERVIEWVIEWMODEL_H
#define PAYMENTSOVERVIEWVIEWMODEL_H

#include <QObject>
#include <QJsonObject>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include "repositories/impl/paymentsoverviewrepositoryimpl.h"
#include "presentation/models/paymentslistmodel.h"

class PaymentsOverviewViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PaymentsListModel* paymentsModel READ paymentsModel CONSTANT)
    Q_PROPERTY(PaymentsListModel* commissionsModel READ commissionsModel CONSTANT)
    Q_PROPERTY(PaymentsListModel* payoutsModel READ payoutsModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(double totalCollected READ totalCollected NOTIFY overviewChanged)
    Q_PROPERTY(int pendingCount READ pendingCount NOTIFY overviewChanged)
    Q_PROPERTY(double commissionsDue READ commissionsDue NOTIFY overviewChanged)
    Q_PROPERTY(int payoutsPending READ payoutsPending NOTIFY overviewChanged)

public:
    explicit PaymentsOverviewViewModel(QObject *parent = nullptr);

    PaymentsListModel* paymentsModel() const { return m_payments; }
    PaymentsListModel* commissionsModel() const { return m_commissions; }
    PaymentsListModel* payoutsModel() const { return m_payouts; }
    bool isLoading() const { return m_isLoading; }

    double totalCollected() const { return m_totalCollected; }
    int pendingCount() const { return m_pendingCount; }
    double commissionsDue() const { return m_commissionsDue; }
    int payoutsPending() const { return m_payoutsPending; }

    Q_INVOKABLE void refresh();

private:
    PaymentsOverviewRepositoryImpl* m_repository = nullptr;
    PaymentsListModel* m_payments = nullptr;
    PaymentsListModel* m_commissions = nullptr;
    PaymentsListModel* m_payouts = nullptr;

    bool m_isLoading = false;
    double m_totalCollected = 0.0;
    int m_pendingCount = 0;
    double m_commissionsDue = 0.0;
    int m_payoutsPending = 0;

    void setLoading(bool loading);
    void applyOverview(const QJsonObject& data);
    static QVector<QVariantMap> listFromJson(const QJsonObject& data, const QString& key);

signals:
    void isLoadingChanged(bool isLoading);
    void overviewChanged();
    void errorOccurred(const QString& error);
};

#endif // PAYMENTSOVERVIEWVIEWMODEL_H