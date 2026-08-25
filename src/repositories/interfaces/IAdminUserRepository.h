#ifndef IADMINUSERREPOSITORY_H
#define IADMINUSERREPOSITORY_H

#include <QObject>
#include "models/user.h"

class IAdminUserRepository : public QObject
{
    Q_OBJECT
public:
    explicit IAdminUserRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    virtual void getUsers() = 0;
    virtual void getUserById(const QString& userId) = 0;
    virtual void updateUserRole(const QString& userId, const QString& role) = 0;
    virtual void setAccountActive(const QString& userId, bool active) = 0;
    virtual ~IAdminUserRepository() {}
};

#endif // IADMINUSERREPOSITORY_H
