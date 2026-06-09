#ifndef USERREPOSITORYIMPL_H
#define USERREPOSITORYIMPL_H

#include "repositories/interfaces/IUserRepository.h"
#include "models/user.h"

class UserRepositoryImpl : public IUserRepository
{
public:
    UserRepositoryImpl();
    User* signIn(
        const QString& email,
        const QString& password) override;
        
    User* signUp(
        const QString& name,
        const QString& email,
        const QString& password,
        const QString& confirmPassword,
        const QString& residentialAddress) override;
        
    User* logOut() override;
private:

};

#endif // USERREPOSITORYIMPL_H
