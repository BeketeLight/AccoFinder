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

    Q_INVOKABLE void raiseDispute(const QString& raisedBy,
                                  const QString& title,
                                  const QString& status,
                                  const QString& description);
    Q_INVOKABLE void resolveDispute(const QString& disputeId, const QString& status);
    Q_INVOKABLE void getDisputes();

private:
    DisputeRepositoryImpl* m_disputeRepository = nullptr;

signals:
    void disputeRaised(Dispute* dispute);
    void disputeResolved(Dispute* dispute);
    void disputesLoaded(QList<Dispute*> disputes);
};

#endif // DISPUTECONTROLLER_H
