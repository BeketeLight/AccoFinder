#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QObject>
#include <QString>
#include "repositories/impl/userrepositoryimpl.h"

class User;

class AuthController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit AuthController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void signIn(const QString& email, const QString& password);
    Q_INVOKABLE void signUp(const QString& fistName,
                            const QString& lastName,
                            const QString& email,
                            const QString& phone,
                            const QString& password,
                            const QString& confirmPassword,
                            const QString& residentialAddress);
    Q_INVOKABLE void logOut();
    Q_INVOKABLE void requestOtp(const QString& email, const QString& purpose);
    Q_INVOKABLE void verifyOtp(const QString& email, const QString& code, const QString& purpose);
    Q_INVOKABLE void checkAccount(const QString& email);

signals:
    void signInSucceded(User* user);
    void signInFailed(const QString& message);
    void signUpSucceded(User* user);
    void signUpFailed(const QString& message);
    void userLoggedOut();
    void emailVerificationRequired(const QString& email);
    void otpRequested(bool status);
    void otpVerified(bool status);
    void accountChecked(const bool& status);
    void isLoadingChanged(bool isLoading);

private:
    void setLoading(bool loading);

    UserRepositoryImpl* m_userRepository = nullptr;
    bool m_isLoading = false;
};

#endif // AUTHCONTROLLER_H
