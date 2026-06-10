#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QObject>
#include "repositories/impl/userrepositoryimpl.h"

class AuthController : public QObject
{
    Q_OBJECT
public:
    explicit AuthController(QObject *parent = nullptr);

    void signIn(QString& email, QString& password);
    void signUp(const QString& name,
                const QString& email,
                const QString& password,
                const QString& confirmPassword,
                const QString& residentialAddress);
    void logOut();
private:
    UserRepositoryImpl* m_userRepository = new UserRepositoryImpl();
signals:
    void signInFailed(QString& message);
    void signUpFailed(QString& message);
    void userLoggedOut();
};

#endif // AUTHCONTROLLER_H
