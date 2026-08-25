#ifndef ADMINUSERREPOSITORYIMPL_H
#define ADMINUSERREPOSITORYIMPL_H

#include <QList>
#include "repositories/interfaces/IAdminUserRepository.h"
#include "application/dto/userdto.h"

class AdminUserRepositoryImpl : public IAdminUserRepository
{
    Q_OBJECT
public:
    explicit AdminUserRepositoryImpl(QObject *parent = nullptr);

    void getUsers() override;
    void getUserById(const QString& userId) override;
    void updateUserRole(const QString& userId, const QString& role) override;
    void setAccountActive(const QString& userId, bool active) override;

signals:
    void usersLoaded(QList<User*>& users);
    void userLoaded(User* user);
    void userUpdated(User* user);
    void userError(const QString& error);
};

#endif // ADMINUSERREPOSITORYIMPL_H
