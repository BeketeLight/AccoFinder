#ifndef DISPUTECONTROLLER_H
#define DISPUTECONTROLLER_H

#include <QList>
#include <QObject>
#include "models/dispute.h"
#include "repositories/impl/disputerepositoryimpl.h"

class DisputeController : public QObject
{
    Q_OBJECT
public:
    explicit DisputeController(QObject *parent = nullptr);
    void raiseDispute(const QString& raisedBy,
                      const QString& title,
                      const QString& status,
                      const QString& description);
    void resolveDispute(const QString& disputeId);
    void getDisputes();
private:
    DisputeRepositoryImpl* m_disputeRepository = nullptr;
    QList<Dispute*> m_disputes;
signals:
    void disputeRaised(Dispute* dispute);
    void disputeResolved(Dispute* dispute);
    void disputesLoaded(QList<Dispute*> disputes);
};

#endif // DISPUTECONTROLLER_H
