#ifndef DISPUTESLISTVIEWMODEL_H
#define DISPUTESLISTVIEWMODEL_H

#include <QObject>

#include "application/dto/disputedto.h"
#include "application/controllers/disputecontroller.h"
#include "presentation/models/disputeslistmodel.h"

class DisputesListViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DisputesListModel *disputesListModel READ disputesListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit DisputesListViewModel(QObject *parent = nullptr);

    DisputesListModel *disputesListModel() const { return m_disputesListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void raiseDispute(const QString &bookingId, const QString &issue);
    Q_INVOKABLE void resolveDispute(int index, const QString &disputeId, const QString &status);
    Q_INVOKABLE void getDisputes();

private:
    void updateLoading();

private slots:
    void onDisputeRaised(const DisputeDto &dispute);
    void onDisputeResolved(const DisputeDto &dispute);
    void onDisputesLoaded(const QList<DisputeDto> &disputes);

signals:
    void isLoadingChanged(bool isLoading);
    void disputeError(const QString &error);

private:
    bool m_listPending = false;
    int m_actionPending = 0;
    bool m_isLoading = false;
    DisputesListModel *m_disputesListModel = nullptr;
    DisputeController *m_disputeController = nullptr;
};

#endif // DISPUTESLISTVIEWMODEL_H
