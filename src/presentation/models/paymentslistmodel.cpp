#include "paymentslistmodel.h"

PaymentsListModel::PaymentsListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int PaymentsListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_rows.size();
}

QVariant PaymentsListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_rows.size())
        return QVariant();

    const QVariantMap row = m_rows.at(index.row());
    const QString key = QString::fromLatin1(
        roleNames().value(role, "#invalid"));
    if (key.isEmpty() || key == "#invalid")
        return QVariant();
    return row.value(key);
}

QHash<int, QByteArray> PaymentsListModel::roleNames() const
{
    QHash<int, QByteArray> mappings;
    const QList<QString> keys = m_rows.isEmpty()
        ? QList<QString>{}
        : m_rows.first().keys();
    int role = Qt::UserRole + 1;
    for (const QString& k : keys) {
        mappings[role++] = k.toUtf8();
    }
    return mappings;
}

void PaymentsListModel::setRows(const QVector<QVariantMap>& rows)
{
    beginResetModel();
    m_rows = rows;
    endResetModel();
    emit countChanged(m_rows.size());
}

void PaymentsListModel::clear()
{
    setRows({});
}

QVariantMap PaymentsListModel::at(int index) const
{
    if (index < 0 || index >= m_rows.size())
        return QVariantMap();
    return m_rows.at(index);
}