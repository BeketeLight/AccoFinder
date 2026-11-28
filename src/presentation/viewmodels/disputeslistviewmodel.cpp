#include "disputeslistviewmodel.h"

DisputesListViewModel::DisputesListViewModel(QObject *parent)
    : QObject(parent),
      m_disputesListModel(new DisputesListModel(this)),
      m_disputeController(new DisputeController(this))
{
    connect(m_disputeController, &DisputeController::disputesLoaded,
            this, &DisputesListViewModel::onDisputesLoaded);
    connect(m_disputeController, &DisputeController::disputeRaised,
            this, &DisputesListViewModel::onDisputeRaised);
    connect(m_disputeController, &DisputeController::disputeResolved,
            this, &DisputesListViewModel::onDisputeResolved);
    connect(m_disputeController, &DisputeController::disputeError,
            this, [this](const QString &error, const QString &operation) {
                if (operation == QStringLiteral("list")) {
                    m_listPending = false;
                } else if ((operation == QStringLiteral("raise")
                            || operation == QStringLiteral("resolve"))
                           && m_actionPending > 0) {
                    --m_actionPending;
                }
                updateLoading();
                emit disputeError(error);
            });
}

void DisputesListViewModel::updateLoading()
{
    const bool loading = m_listPending || m_actionPending > 0;
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(m_isLoading);
    }
}

void DisputesListViewModel::raiseDispute(const QString &bookingId, const QString &issue)
{
    if (bookingId.isEmpty() || issue.trimmed().isEmpty()) {
        emit disputeError(QStringLiteral("Booking and issue are required"));
        return;
    }

    ++m_actionPending;
    updateLoading();
    m_disputeController->raiseDispute(bookingId, issue.trimmed());
}

void DisputesListViewModel::resolveDispute(int index, const QString &disputeId,
                                           const QString &status)
{
    Q_UNUSED(index)

    if (disputeId.isEmpty()) {
        emit disputeError(QStringLiteral("Dispute id is required"));
        return;
    }

    ++m_actionPending;
    updateLoading();
    m_disputeController->resolveDispute(disputeId, status);
}

void DisputesListViewModel::getDisputes()
{
    // The repository coalesces in-flight loads; skip duplicates here too so
    // the loading state stays consistent with the single response we receive.
    if (m_listPending)
        return;

    m_listPending = true;
    updateLoading();
    m_disputeController->getDisputes();
}

void DisputesListViewModel::onDisputeRaised(const DisputeDto &dispute)
{
    if (m_actionPending > 0)
        --m_actionPending;
    updateLoading();
    m_disputesListModel->addDispute(dispute);
}

void DisputesListViewModel::onDisputeResolved(const DisputeDto &dispute)
{
    if (m_actionPending > 0)
        --m_actionPending;
    updateLoading();
    // Match by id rather than a cached row index: a reload may have happened
    // while the resolve request was in flight.
    m_disputesListModel->updateDispute(dispute);
}

void DisputesListViewModel::onDisputesLoaded(const QList<DisputeDto> &disputes)
{
    if (!m_listPending)
        return;

    m_listPending = false;
    updateLoading();
    m_disputesListModel->setDisputes(disputes);
}
