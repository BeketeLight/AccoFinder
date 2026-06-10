#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include "repositories/impl/userrepositoryimpl.h"

class AuthController
{
public:
    AuthController();

    void signIn(QString& email, QString& password);
    void signUp(const QString& name,
                const QString& email,
                const QString& password,
                const QString& confirmPassword,
                const QString& residentialAddress);
    void logOut();
private:
    UserRepositoryImpl* m_userRepository = new UserRepositoryImpl();
};

#endif // AUTHCONTROLLER_H
