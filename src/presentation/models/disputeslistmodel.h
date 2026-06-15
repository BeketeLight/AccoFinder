#ifndef DISPUTESLISTMODEL_H
#define DISPUTESLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QList>
#include <QHash>
#include <QByteArray>
#include "models/dispute.h"
#include "core/utils/EDisputeStatus.h"

class DisputesListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum roles{
        IdRole = Qt::UserRole+1,
        BookingIdRole,
        IssueRole,
        StatusRole
    };
    DisputesListModel();
    explicit DisputesListModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int,QByteArray> roleNames() const override;
    void addDisputes(QList<Dispute*>& disputes);

    void updateDispute(int index,Dispute* newDispute);

private:
    QVector<Dispute*> m_disputes;
};

#endif // DISPUTESLISTMODEL_H
