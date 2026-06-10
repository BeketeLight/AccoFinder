#ifndef USERREPOSITORYIMPL_H
#define USERREPOSITORYIMPL_H

#include "repositories/interfaces/IUserRepository.h"
#include "models/user.h"

class UserRepositoryImpl : public IUserRepository
{
    Q_OBJECT
public:
   explicit UserRepositoryImpl(QObject *parent = nullptr);
    void signIn(
        const QString& email,
        const QString& password) override;
        
    void signUp(
        const QString& name,
        const QString& email,
        const QString& password,
        const QString& confirmPassword,
        const QString& residentialAddress) override;
        
    void logOut() override;

signals:
        void signInSucceded(User* user);
        void signInFailed(const QString& error);

        void signUpSucceded(User* user);
        void signUpFailed(const QString& error);

        void logOutSuccess();
};

#endif // USERREPOSITORYIMPL_H
