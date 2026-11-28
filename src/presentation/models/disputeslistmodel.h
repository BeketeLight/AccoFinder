#ifndef DISPUTESLISTMODEL_H
#define DISPUTESLISTMODEL_H

#include <QAbstractListModel>
#include <QByteArray>
#include <QHash>
#include <QList>
#include <QVariantMap>
#include <QVector>

#include "application/dto/disputedto.h"
#include "core/utils/EDisputeStatus.h"

class DisputesListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Role {
        IdRole = Qt::UserRole + 1,
        BookingIdRole,
        IssueRole,
        StatusRole
    };
    Q_ENUM(Role)

    DisputesListModel();
    explicit DisputesListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const { return m_disputes.size(); }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Replaces the whole list with freshly created, model-owned Dispute objects.
    void setDisputes(const QList<DisputeDto> &disputes);

    // Upserts by id: a late "raised" response cannot duplicate a row that a
    // subsequent list load already contains.
    void addDispute(const DisputeDto &dispute);

    // Updates an existing row in place; safe after a reload changed row indexes.
    void updateDispute(const DisputeDto &dispute);
    void updateDispute(int index, const DisputeDto &dispute);

    Q_INVOKABLE int size() const { return m_disputes.size(); }
    Q_INVOKABLE QVariantMap at(int index) const;

signals:
    void countChanged(int newCount);

private:
    int rowById(const QString &id) const;
    void applyDto(Dispute *target, const DisputeDto &dto);

    // Every Dispute here is created with `this` as its parent. No other layer
    // may delete these pointers.
    QVector<Dispute *> m_disputes;
};

#endif // DISPUTESLISTMODEL_H
