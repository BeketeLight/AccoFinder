#ifndef DISPUTESLISTVIEWMODEL_H
#define DISPUTESLISTVIEWMODEL_H

#include <QObject>
#include "presentation/models/disputeslistmodel.h"
#include "application/controllers/disputecontroller.h"

class DisputesListViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DisputesListModel* disputesListModel READ disputesListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit DisputesListViewModel(QObject *parent = nullptr);

    DisputesListModel* disputesListModel() const { return m_disputesListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void raiseDispute(int index,
                                  const QString& raisedBy,
                                  const QString& title,
                                  const QString& status,
                                  const QString& description);
    Q_INVOKABLE void resolveDispute(int index, const QString& disputeId);
    Q_INVOKABLE void getDisputes();

private:
    int m_index = -1;
    bool m_isLoading = false;
    DisputesListModel* m_disputesListModel = nullptr;
    DisputeController* m_disputeController = nullptr;

    void setLoading(bool loading);

private slots:
    void onDisputeRaised(Dispute* dispute);
    void onDisputeResolved(Dispute* dispute);
    void onDisputesLoaded(QList<Dispute*> disputes);

signals:
    void isLoadingChanged(bool isLoading);
    void disputeError(const QString& error);
};

#endif // DISPUTESLISTVIEWMODEL_H
