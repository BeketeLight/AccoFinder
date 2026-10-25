#include "disputecontroller.h"

DisputeController::DisputeController(QObject *parent)
    : QObject{parent},
      m_disputeRepository(new DisputeRepositoryImpl(this))
{
    connect(m_disputeRepository,&DisputeRepositoryImpl::disputesLoaded,
            this,&DisputeController::disputesLoaded);
    connect(m_disputeRepository,&DisputeRepositoryImpl::disputeRaised,
            this,&DisputeController::disputeRaised);
    connect(m_disputeRepository,&DisputeRepositoryImpl::disputeResolved,
            this,&DisputeController::disputeResolved);
}

void DisputeController::raiseDispute(const QString& bookingId,const QString& issue)
{
    m_disputeRepository->raiseDispute(bookingId,issue);
}

void DisputeController::resolveDispute(const QString& disputeId, const QString& status)
{
    m_disputeRepository->resolveDispute(disputeId, status);
}

void DisputeController::getDisputes()
{
    m_disputeRepository->getDisputes();

}
