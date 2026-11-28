#ifndef DISPUTECONTROLLER_H
#define DISPUTECONTROLLER_H

#include <QList>
#include <QObject>

#include "application/dto/disputedto.h"
#include "repositories/impl/disputerepositoryimpl.h"

class DisputeController : public QObject
{
    Q_OBJECT
public:
    explicit DisputeController(QObject *parent = nullptr);

    Q_INVOKABLE void raiseDispute(const QString &bookingId, const QString &issue);
    Q_INVOKABLE void resolveDispute(const QString &disputeId, const QString &status);
    Q_INVOKABLE void getDisputes();

private:
    DisputeRepositoryImpl *m_disputeRepository = nullptr;

signals:
    void disputeRaised(const DisputeDto &dispute);
    void disputeResolved(const DisputeDto &dispute);
    void disputesLoaded(const QList<DisputeDto> &disputes);
    void disputeError(const QString &error, const QString &operation);
};

#endif // DISPUTECONTROLLER_H
