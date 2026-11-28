#ifndef DISPUTEREPOSITORYIMPL_H
#define DISPUTEREPOSITORYIMPL_H

#include <QtGlobal>

#include "repositories/interfaces/IDisputeRepository.h"

class DisputeRepositoryImpl : public IDisputeRepository
{
    Q_OBJECT
public:
    explicit DisputeRepositoryImpl(QObject *parent = nullptr);

    void raiseDispute(const QString &bookingId, const QString &issue) override;
    void resolveDispute(const QString &disputeId, const QString &status) override;
    void getDisputes() override;

private:
    // Rapid footer taps used to fire several identical loads at once. One
    // in-flight request is enough; the generation rejects a late reply from a
    // request that has since been superseded.
    quint64 m_getGeneration = 0;
    bool m_getInFlight = false;
};

#endif // DISPUTEREPOSITORYIMPL_H
