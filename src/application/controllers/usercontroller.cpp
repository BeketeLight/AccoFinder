#include "usercontroller.h"

UserController::UserController(QObject *parent)
    : QObject(parent),
      m_repository(new AdminUserRepositoryImpl(this))
{
    connect(m_repository, &AdminUserRepositoryImpl::usersLoaded,
            this, &UserController::usersLoaded);
    connect(m_repository, &AdminUserRepositoryImpl::userLoaded,
            this, &UserController::userLoaded);
    connect(m_repository, &AdminUserRepositoryImpl::userUpdated,
            this, &UserController::userUpdated);
    connect(m_repository, &AdminUserRepositoryImpl::userError,
            this, &UserController::userError);
}

void UserController::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void UserController::getUsers()
{
    setLoading(true);
    m_repository->getUsers();
}

void UserController::getUserById(const QString &userId)
{
    if (userId.isEmpty()) {
        emit userError("userId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->getUserById(userId);
}

void UserController::updateUserRole(const QString &userId, const QString &role)
{
    if (userId.isEmpty()) {
        emit userError("userId cannot be empty");
        return;
    }
    if (role.isEmpty()) {
        emit userError("role cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->updateUserRole(userId, role);
}

void UserController::setAccountActive(const QString &userId, bool active)
{
    if (userId.isEmpty()) {
        emit userError("userId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->setAccountActive(userId, active);
}
