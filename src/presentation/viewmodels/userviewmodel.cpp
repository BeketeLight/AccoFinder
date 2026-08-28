#include "userviewmodel.h"
#include <algorithm>

UserViewModel::UserViewModel(QObject *parent)
    : QObject(parent),
      m_userListModel(new UserListModel(this)),
      m_userController(new UserController(this))
{
    connect(m_userController, &UserController::usersLoaded,
            this, &UserViewModel::onUsersLoaded);
    connect(m_userController, &UserController::userUpdated,
            this, &UserViewModel::onUserUpdated);
    connect(m_userController, &UserController::userError,
            this, &UserViewModel::onUserError);
}

void UserViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void UserViewModel::getUsers()
{
    setLoading(true);
    m_userController->getUsers();
}

void UserViewModel::updateRole(const QString &userId, const QString &role)
{
    setLoading(true);
    m_userController->updateUserRole(userId, role);
}

void UserViewModel::setActive(const QString &userId, bool active)
{
    setLoading(true);
    m_userController->setAccountActive(userId, active);
}

void UserViewModel::addUser(const QString &firstName, const QString &lastName,
                            const QString &email, const QString &phone,
                            const QString &role, const QString &residentialAddress)
{
    User* user = new User();
    user->setFirstName(firstName);
    user->setLastName(lastName);
    user->setEmail(email);
    user->setPhone(phone);
    user->setRole(role);
    user->setResidentialAddress(residentialAddress);
    user->setCreatedAt(QDateTime::currentDateTime());
    m_userListModel->addUser(user);
    emit userAdded(email);
}

QVariantMap UserViewModel::findUserByEmail(const QString &email) const
{
    for (int i = 0; i < m_userListModel->rowCount(); ++i) {
        const QModelIndex idx = m_userListModel->index(i, 0);
        if (m_userListModel->data(idx, UserListModel::EmailRole).toString().compare(email, Qt::CaseInsensitive) == 0) {
            QVariantMap row;
            row["userId"] = m_userListModel->data(idx, UserListModel::IdRole);
            row["name"] = m_userListModel->data(idx, UserListModel::NameRole);
            row["email"] = m_userListModel->data(idx, UserListModel::EmailRole);
            row["phone"] = m_userListModel->data(idx, UserListModel::PhoneRole);
            row["role"] = m_userListModel->data(idx, UserListModel::RoleRole);
            row["joined"] = m_userListModel->data(idx, UserListModel::JoinedRole);
            row["active"] = m_userListModel->data(idx, UserListModel::ActiveRole);
            return row;
        }
    }
    return QVariantMap();
}

int UserViewModel::activeCount() const
{
    int c = 0;
    for (int i = 0; i < m_userListModel->rowCount(); ++i) {
        if (m_userListModel->data(m_userListModel->index(i, 0), UserListModel::ActiveRole).toBool())
            ++c;
    }
    return c;
}

int UserViewModel::suspendedCount() const
{
    return m_userListModel->rowCount() - activeCount();
}

void UserViewModel::onUsersLoaded(QList<User *> &users)
{
    setLoading(false);
    m_userListModel->setUsers(users);
}

void UserViewModel::onUserUpdated(User *user)
{
    setLoading(false);
    m_userListModel->updateUserById(user->getId(), user);
}

void UserViewModel::onUserError(const QString &error)
{
    setLoading(false);
    emit userError(error);
}
