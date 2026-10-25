#include "disputeslistviewmodel.h"

DisputesListViewModel::DisputesListViewModel(QObject *parent)
    : QObject{parent},
      m_disputesListModel(new DisputesListModel(this)),
      m_disputeController(new DisputeController(this))
{
    connect(m_disputeController, &DisputeController::disputesLoaded,
            this, &DisputesListViewModel::onDisputesLoaded);
    connect(m_disputeController, &DisputeController::disputeRaised,
            this, &DisputesListViewModel::onDisputeRaised);
    connect(m_disputeController, &DisputeController::disputeResolved,
            this, &DisputesListViewModel::onDisputeResolved);
}

void DisputesListViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void DisputesListViewModel::raiseDispute(const QString &bookingId, const QString &issue)
{
    //m_index = index;
    if(bookingId.isEmpty() || issue.trimmed().isEmpty()){
        emit disputeError(QStringLiteral("Booking and issue are required"));
        return;
    }
    setLoading(true);
    m_disputeController->raiseDispute(bookingId, issue);
}

void DisputesListViewModel::resolveDispute(int index, const QString &disputeId, const QString &status)
{
    m_index = index;
    setLoading(true);
    m_disputeController->resolveDispute(disputeId, status);
}

void DisputesListViewModel::getDisputes()
{
    setLoading(true);
    m_disputeController->getDisputes();
}

void DisputesListViewModel::onDisputeRaised(Dispute *dispute)
{
    setLoading(false);
    m_disputesListModel->updateDispute(m_index, dispute);
}

void DisputesListViewModel::onDisputeResolved(Dispute *dispute)
{
    setLoading(false);
    //New dispute append
    m_disputesListModel->addDispute(dispute);
}

void DisputesListViewModel::onDisputesLoaded(QList<Dispute *> disputes)
{
    setLoading(false);
    m_disputesListModel->addDisputes(disputes);
}
