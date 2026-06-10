#ifndef VERIFICATIONCONTROLLER_H
#define VERIFICATIONCONTROLLER_H

#include <QObject>
#include "models/verification.h"
#include "repositories/impl/verificationrepositoryimpl.h"

class VerificationController : public QObject
{
    Q_OBJECT
public:
    explicit VerificationController(QObject *parent = nullptr);
    Verification* createVerification();
    Verification* getVerificationHistory();
    Verification* approveProperty();
    Verification* rejectProperty();
private:
    VerificationRepositoryImpl *m_verificationRepositoryImpl = new VerificationRepositoryImpl();

signals:
};

#endif // VERIFICATIONCONTROLLER_H
