#ifndef DISPUTEREPOSITORYIMPL_H
#define DISPUTEREPOSITORYIMPL_H

#include "repositories/interfaces/IDisputeRepository.h"
#include "models/dispute.h"

class DisputeRepositoryImpl : public IDisputeRepository
{
public:
    DisputeRepositoryImpl();
    Dispute* raiseDispute() override;
    Dispute* resolveDispute() override;
private:
    Dispute* dispute = new Dispute;

};

#endif // DISPUTEREPOSITORYIMPL_H
