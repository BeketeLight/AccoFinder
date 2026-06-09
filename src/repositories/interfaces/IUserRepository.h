#ifndef IUSERREPOSITORY_H
#define IUSERREPOSITORY_H

#include <QObject>
#include "models/user.h"

class IUserRepository : public QObject
{
    Q_OBJECT
public:
    explicit IUserRepository(QObject *parent =nullptr)
        : QObject(parent) {}
    virtual User* signIn(
        const QString& email,
        const QString& password) = 0;

    virtual User* signUp(
        const QString& name,
        const QString& email,
        const QString& password,
        const QString& confirmPassword,
        const QString& residentialAddress) = 0;

    virtual User* logOut() = 0;

    virtual ~IUserRepository(){}
private:
signals:
    void signInSucceded(User* user);
    void signInFailed(const QString& error);

    void signUpSuccess(User* user);
    void signUpFailed(const QString& error);    

    void logOutSuccess();
};

#endif // IUSERREPOSITORY_H
