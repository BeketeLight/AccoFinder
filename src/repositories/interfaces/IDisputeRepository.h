#ifndef IDISPUTEREPOSITORY_H
#define IDISPUTEREPOSITORY_H

#include <QObject>
#include "models/dispute.h"

class IDisputeRepository : public QObject
{
    Q_OBJECT
public:
    explicit IDisputeRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    virtual void raiseDispute(const QString& raisedBy,
                              const QString& title,
                              const QString& status,
                              const QString& description) = 0;

    //virtual void getDisputes() = 0;

    virtual void resolveDispute(const QString& disputeId) = 0;

    virtual ~IDisputeRepository() {}

};

#endif // IDISPUTEREPOSITORY_H
