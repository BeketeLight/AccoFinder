#include "usercontroller.h"

UserController::UserController(QObject *parent)
    : QObject(parent),
      m_repository(new AdminUserRepositoryImpl(this))
{
    connect(m_repository, &AdminUserRepositoryImpl::usersLoaded,
            this, [this](QList<User*>& users) {
                setLoading(false);
                emit usersLoaded(users);
            });
    connect(m_repository, &AdminUserRepositoryImpl::userLoaded,
            this, [this](User* user) {
                setLoading(false);
                emit userLoaded(user);
            });
    connect(m_repository, &AdminUserRepositoryImpl::userUpdated,
            this, [this](User* user) {
                setLoading(false);
                emit userUpdated(user);
            });
    connect(m_repository, &AdminUserRepositoryImpl::userDeleted,
            this, [this](const QString& userId) {
                setLoading(false);
                emit userDeleted(userId);
            });
    connect(m_repository, &AdminUserRepositoryImpl::userError,
            this, [this](const QString& error) {
                setLoading(false);
                emit userError(error);
            });
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

void UserController::toggleUserStatus(const QString &userId, bool active)
{
    setAccountActive(userId, active);
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

void UserController::deleteUser(const QString &userId)
{
    if (userId.isEmpty()) {
        emit userError("userId cannot be empty");
        return;
    }
    setLoading(true);
    m_repository->deleteUser(userId);
}
