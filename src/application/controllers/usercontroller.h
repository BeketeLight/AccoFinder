#ifndef USERCONTROLLER_H
#define USERCONTROLLER_H

#include <QObject>
#include <QList>
#include "models/user.h"
#include "repositories/impl/adminuserrepositoryimpl.h"

class UserController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit UserController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getUsers();
    Q_INVOKABLE void getUserById(const QString& userId);
    Q_INVOKABLE void updateUserRole(const QString& userId, const QString& role);
    Q_INVOKABLE void setAccountActive(const QString& userId, bool active);

signals:
    void usersLoaded(QList<User*>& users);
    void userLoaded(User* user);
    void userUpdated(User* user);
    void userError(const QString& error);
    void isLoadingChanged(bool isLoading);

private:
    AdminUserRepositoryImpl* m_repository = nullptr;
    bool m_isLoading = false;

    void setLoading(bool loading);
};

#endif // USERCONTROLLER_H
