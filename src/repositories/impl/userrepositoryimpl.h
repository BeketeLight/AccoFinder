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
        const QString& fistName,
        const QString& lastName,
        const QString& email,
        const QString& phone,
        const QString& password,
        const QString& confirmPassword,
        const QString& residentialAddress) override;
        
    void logOut() override;
    void requestOtp(const QString& email, const QString& purpose) override;
    void verifyOtp(const QString& email, const QString& code, const QString& purpose) override;
    void checkAccount(const QString& email) override;

signals:
        void signInSucceded(User* user);
        void signInFailed(const QString& error);
        void signUpSucceded(User* user);
        void signUpFailed(const QString& error);
        void logOutSucceded();
        void emailVerificationRequired(const QString& email);
        void otpRequested(bool status);
        void otpVerified(bool status);
        void accountChecked(const bool& status);
};

#endif // USERREPOSITORYIMPL_H
