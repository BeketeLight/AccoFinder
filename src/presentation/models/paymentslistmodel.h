#ifndef PAYMENTSLISTMODEL_H
#define PAYMENTSLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QByteArray>
#include <QVariantMap>

// Row-oriented list model backed by QVariantMap rows. Used to surface the
// payments / commissions / payouts oversight lists from the dashboard API so
// the QML delegates can read arbitrary columns (paymentId, amount, status,
// method, agent, landlord, etc.) without a fixed role enum.
class PaymentsListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit PaymentsListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const { return m_rows.size(); }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setRows(const QVector<QVariantMap>& rows);
    void clear();

    Q_INVOKABLE int size() const { return m_rows.size(); }
    Q_INVOKABLE QVariantMap at(int index) const;

signals:
    void countChanged(int newCount);

private:
    QVector<QVariantMap> m_rows;
};

#endif // PAYMENTSLISTMODEL_H