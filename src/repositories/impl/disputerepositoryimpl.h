#ifndef DISPUTEREPOSITORYIMPL_H
#define DISPUTEREPOSITORYIMPL_H

#include <QList>
#include "repositories/interfaces/IDisputeRepository.h"
#include "models/dispute.h"
#include "application/dto/disputedto.h"

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
    void getDisputes() override;

private:
    QList<Dispute*> m_disputes;

signals:
    void disputeRaised(Dispute* dispute);
    void disputesLoaded(QList<Dispute*>& disputes);
    void disputeResolved(Dispute* dispute);
    void disputeError(const QString& error);


};

#endif // DISPUTEREPOSITORYIMPL_H
