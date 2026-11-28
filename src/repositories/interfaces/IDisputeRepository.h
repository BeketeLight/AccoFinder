#ifndef IDISPUTEREPOSITORY_H
#define IDISPUTEREPOSITORY_H

#include <QObject>
#include "application/dto/disputedto.h"

class IDisputeRepository : public QObject
{
    Q_OBJECT
public:
    explicit IDisputeRepository(QObject *parent = nullptr)
        : QObject(parent) {}

    virtual void raiseDispute(const QString &bookingId, const QString &issue) = 0;
    virtual void resolveDispute(const QString &disputeId, const QString &status) = 0;
    virtual void getDisputes() = 0;

    virtual ~IDisputeRepository() {}

signals:
    // Values, not raw pointers: receivers must never share object ownership.
    void disputeRaised(const DisputeDto &dispute);
    void disputeResolved(const DisputeDto &dispute);
    void disputesLoaded(const QList<DisputeDto> &disputes);

    // `operation` is "list", "raise" or "resolve" so the view model can clear
    // only the loading state that actually failed.
    void disputeError(const QString &error, const QString &operation);
};

#endif // IDISPUTEREPOSITORY_H
