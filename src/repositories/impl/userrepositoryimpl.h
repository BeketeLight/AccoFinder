#ifndef USERREPOSITORYIMPL_H
#define USERREPOSITORYIMPL_H

#include "repositories/interfaces/IUserRepository.h"
#include "models/user.h"

class UserRepositoryImpl : public IUserRepository
{
public:
    UserRepositoryImpl();
    User* signIn() override;
    User* signUp() override;
    User* logOut() override;
private:

};

#endif // USERREPOSITORYIMPL_H
