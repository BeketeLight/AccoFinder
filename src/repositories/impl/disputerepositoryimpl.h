#ifndef DISPUTEREPOSITORYIMPL_H
#define DISPUTEREPOSITORYIMPL_H

#include "repositories/interfaces/IDisputeRepository.h"
#include "models/dispute.h"

class DisputeRepositoryImpl : public IDisputeRepository
{
    Q_OBJECT
public:
    explicit DisputeRepositoryImpl(QObject *parent = nullptr);
    void raiseDispute(const QString& raisedBy,
        const QString& title,
        const QString& status,
        const QString& description
        ) override;

    //void getDisputes() override;    

    void resolveDispute(const QString& disputeId) override;

signals:
    void disputeRaised(Dispute* dispute);
    //void disputesLoaded(const QList<Dispute*>& disputes);
    void disputeResolved(Dispute* dispute);
    void disputeError(const QString& error);

};

#endif // DISPUTEREPOSITORYIMPL_H
