#ifndef IVERIFICATIONREPOSITORY_H
#define IVERIFICATIONREPOSITORY_H

#include "models/verification.h"


class IVerificationRepository {
public:
    virtual Verification createVerification();
    virtual Verification getVerificationHistory();
    virtual Verification approveProperty();
    virtual Verification rejectProperty();
};

#endif // IVERIFICATIONREPOSITORY_H
