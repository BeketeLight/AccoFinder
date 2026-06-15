#ifndef DISPUTESLISTVIEWMODEL_H
#define DISPUTESLISTVIEWMODEL_H

#include <QObject>
#include <QSharedPointer>
#include "presentation/models/disputeslistmodel.h"
#include "application/controllers/disputecontroller.h"

class DisputesListViewModel : public QObject
{
    Q_OBJECT
public:
    explicit DisputesListViewModel(QObject *parent = nullptr);

    Q_INVOKABLE void raiseDispute(int index,
                                  const QString& raisedBy,
                                  const QString& title,
                                  const QString& status,
                                  const QString& description);
    Q_INVOKABLE void resolveDispute(int index,const QString& disputeId);
    Q_INVOKABLE void getDisputes();
private:
    int m_index;
    QSharedPointer<DisputesListModel> m_disputesListModel ;
    QSharedPointer <DisputeController> m_disputeController;
private slots:
    void onDisputeRaised(Dispute* dispute);
    void onDisputeResolved(Dispute* dispute);
    void onDisputesLoaded(QList<Dispute*> disputes);
signals:
};

#endif // DISPUTESLISTVIEWMODEL_H
