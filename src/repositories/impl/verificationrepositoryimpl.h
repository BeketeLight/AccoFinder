#ifndef VERIFICATIONREPOSITORYIMPL_H
#define VERIFICATIONREPOSITORYIMPL_H

#include "repositories/interfaces/IVerificationRepository.h"
#include "application/dto/verificationdto.h"
#include "models/verification.h"

class VerificationRepositoryImpl : public IVerificationRepository
{
    Q_OBJECT
public:
   explicit VerificationRepositoryImpl(QObject* parent = nullptr);

   void createVerification(const QString& id, 
                           const QString& agentId, 
                           const QString& propertyId, 
                           const QString& notes, 
                           const QDateTime& verifiedAt,
                           VerificationStatus& status) override;

   void getVerificationHistory() override;

   void approveProperty(const QString& id,
                        const QString& propertyId, 
                        const QString& agentId, 
                        const QString& notes, 
                        const QDateTime& verifiedAt, 
                        VerificationStatus& status) override;

   void rejectProperty(const QString& id,
                       const QString& propertyId, 
                       const QString& agentId, 
                       const QString& notes, 
                       const QDateTime& verifiedAt, 
                       VerificationStatus& status) override;

signals:
    void propertyCreated(Verification* verification);
    void propertyRejected(Verification* verification);
    void propertyHistoryLoaded(const QList<Verification*>& verfications);
    void propertyApproved(Verification* verification) ;
    void propertyError(const QString& error);
};

#endif // VERIFICATIONREPOSITORYIMPL_H
