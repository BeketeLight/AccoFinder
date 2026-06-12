#ifndef IVERIFICATIONREPOSITORY_H
#define IVERIFICATIONREPOSITORY_H

#include <QObject>
#include "models/verification.h"


class IVerificationRepository : public QObject
{
    Q_OBJECT
public:
    explicit IVerificationRepository(QObject *parent = nullptr )
        : QObject(parent) {}

    virtual void createVerification(const QString& id, 
                                    const QString& agentId, 
                                    const QString& propertyId, 
                                    const QString& notes, 
                                    const QDateTime& verifiedAt, 
                                    VerificationStatus& status) = 0;

    virtual void getVerificationHistory() = 0;

    virtual void approveProperty(const QString& id,
                                const QString& agentId, 
                                const QString& propertyId, 
                                const QString& notes, 
                                const QDateTime& verifiedAt, 
                                VerificationStatus& status) = 0;
    virtual void rejectProperty(const QString& id, 
                                const QString& agentId, 
                                const QString& propertyId, 
                                const QString& notes, 
                                const QDateTime& verifiedAt, 
                                VerificationStatus& status) = 0;

    virtual ~IVerificationRepository(){}
};

#endif // IVERIFICATIONREPOSITORY_H
