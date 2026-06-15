#include "disputeslistviewmodel.h"

DisputesListViewModel::DisputesListViewModel(QObject *parent)
    : QObject{parent}
{
    connect(m_disputeController.data(),&DisputeController::disputesLoaded,
            this, &DisputesListViewModel::onDisputesLoaded);
    connect(m_disputeController.data(),&DisputeController::disputeRaised,
            this,&DisputesListViewModel::onDisputeRaised);
    connect(m_disputeController.data(),&DisputeController::disputeResolved,
            this,&DisputesListViewModel::onDisputeResolved);
}

void DisputesListViewModel::raiseDispute(int index,const QString &raisedBy, const QString &title, const QString &status, const QString &description)
{
    m_disputeController->raiseDispute(raisedBy,title,status,description);
    m_index = index;
}

void DisputesListViewModel::resolveDispute(int index,const QString &disputeId)
{
    m_disputeController->resolveDispute(disputeId);
    m_index = index;
}

void DisputesListViewModel::getDisputes()
{
    m_disputeController->getDisputes();
}

void DisputesListViewModel::onDisputeRaised(Dispute *dispute)
{
    m_disputesListModel->updateDispute(m_index,dispute);
}

void DisputesListViewModel::onDisputeResolved(Dispute *dispute)
{
    m_disputesListModel->updateDispute(m_index,dispute);
}

void DisputesListViewModel::onDisputesLoaded(QList<Dispute *> disputes)
{
    m_disputesListModel->addDisputes(disputes);
}
