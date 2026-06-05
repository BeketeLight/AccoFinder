#ifndef IDISPUTEREPOSITORY_H
#define IDISPUTEREPOSITORY_H

#include <QObject>
#include "models/dispute.h"

class IDisputeRepository : public QObject
{
    Q_OBJECT
public:
    explicit IDisputeRepository(QObject *parent = nullptr);
    virtual Dispute raiseDispute() = 0;
    virtual Dispute resolveDispute() = 0;

private:
signals:
};

#endif // IDISPUTEREPOSITORY_H
