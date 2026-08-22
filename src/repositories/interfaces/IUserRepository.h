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
    virtual void signIn(
        const QString& email,
        const QString& password) = 0;

    virtual void signUp(
        const QString& fistName,
        const QString& lastName,
        const QString& email,
        const QString& phone,
        const QString& password,
        const QString& confirmPassword,
        const QString& residentialAddress) = 0;

    virtual void logOut() = 0;
    virtual void requestOtp(const QString& email, const QString& purpose) = 0;
    virtual void verifyOtp(const QString& email, const QString& code, const QString& purpose) = 0;
    virtual void checkAccount(const QString& email) =0;

    virtual ~IUserRepository(){}

};

#endif // IUSERREPOSITORY_H
