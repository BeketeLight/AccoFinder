#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QObject>
#include "repositories/impl/userrepositoryimpl.h"

class User;

class AuthController : public QObject
{
    Q_OBJECT
public:
    explicit AuthController(QObject *parent = nullptr);

    void signIn(const QString& email, const QString& password);
    void signUp(const QString& name,
                const QString& email,
                const QString& password,
                const QString& confirmPassword,
                const QString& residentialAddress);
    void logOut();
private:
    UserRepositoryImpl* m_userRepository = new UserRepositoryImpl();
signals:
    void signInSucceded(User* user);
    void signInFailed(const QString& message);
    void signUpSucceded(User* user);
    void signUpFailed(const QString& message);
    void userLoggedOut();
};

#endif // AUTHCONTROLLER_H
