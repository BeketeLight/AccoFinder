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
    virtual User* signIn() = 0;
    virtual User* signUp() = 0;
    virtual User* logOut() = 0;

    virtual ~IUserRepository(){}
private:
signals:
};

#endif // IUSERREPOSITORY_H
