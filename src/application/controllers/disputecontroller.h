#ifndef DISPUTECONTROLLER_H
#define DISPUTECONTROLLER_H

#include <QObject>
#include "models/dispute.h"
#include "repositories/impl/disputerepositoryimpl.h"

class DisputeController : public QObject
{
    Q_OBJECT
public:
    explicit DisputeController(QObject *parent = nullptr);
    Dispute* raiseDispute();
    Dispute* resolveDispute();
signals:
};

#endif // DISPUTECONTROLLER_H
