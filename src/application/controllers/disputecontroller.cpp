#include "disputecontroller.h"

DisputeController::DisputeController(QObject *parent)
    : QObject{parent}
{
    connect(m_disputeRepository,&DisputeRepositoryImpl::disputesLoaded,
            this,&DisputeController::disputesLoaded);
    connect(m_disputeRepository,&DisputeRepositoryImpl::disputeRaised,
            this,&DisputeController::disputeRaised);
    connect(m_disputeRepository,&DisputeRepositoryImpl::disputeResolved,
            this,&DisputeController::disputeResolved);
}

void DisputeController::raiseDispute(const QString& raisedBy,
                                     const QString& title,
                                     const QString& status,
                                     const QString& description)
{
    m_disputeRepository->raiseDispute(raisedBy,title,status,description);
}

void DisputeController::resolveDispute(const QString& disputeId)
{
    m_disputeRepository->resolveDispute(disputeId);
}

void DisputeController::getDisputes()
{
    m_disputeRepository->getDisputes();

}
