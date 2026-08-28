#include "userlistmodel.h"

UserListModel::UserListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int UserListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_users.size();
}

QVariant UserListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_users.size())
        return QVariant();

    User* user = m_users.at(index.row());
    switch (role)
    {
        case IdRole:
            return user->getId();
        case NameRole:
            return user->getFullName();
        case EmailRole:
            return user->getEmail();
        case PhoneRole:
            return user->getPhone();
        case RoleRole:
            return user->getRole();
        case JoinedRole:
            return user->getCreatedAt().isValid()
                    ? user->getCreatedAt().toString("dd MMM yyyy")
                    : QString();
        case ActiveRole:
            return user->isActive();
    }
    return QVariant();
}

QHash<int, QByteArray> UserListModel::roleNames() const
{
    static QHash<int,QByteArray> mapping{
        {IdRole, "userId"},
        {NameRole, "name"},
        {EmailRole, "email"},
        {PhoneRole, "phone"},
        {RoleRole, "role"},
        {JoinedRole, "joined"},
        {ActiveRole, "active"}
    };
    return mapping;
}

void UserListModel::setUsers(QList<User *> users)
{
    beginResetModel();
    qDeleteAll(m_users);
    m_users.clear();
    for (User* u : users)
        m_users.append(u);
    endResetModel();
    emit countChanged(m_users.size());
}

void UserListModel::addUser(User *user)
{
    beginInsertRows(QModelIndex(), m_users.size(), m_users.size());
    m_users.append(user);
    endInsertRows();
    emit countChanged(m_users.size());
}

void UserListModel::updateUser(int index, User *user)
{
    if (index < 0 || index >= m_users.size())
        return;
    beginResetModel();
    delete m_users.at(index);
    m_users[index] = user;
    endResetModel();
}

void UserListModel::updateUserById(const QString &userId, User *user)
{
    int idx = indexOfId(userId);
    if (idx >= 0)
        updateUser(idx, user);
    else
        addUser(user);
}

int UserListModel::indexOfId(const QString &userId) const
{
    for (int i = 0; i < m_users.size(); ++i) {
        if (m_users.at(i)->getId() == userId)
            return i;
    }
    return -1;
}

QVariantMap UserListModel::at(int index) const
{
    if (index < 0 || index >= m_users.size())
        return QVariantMap();
    const QModelIndex idx = this->index(index, 0);
    QVariantMap row;
    row["userId"] = data(idx, IdRole);
    row["name"] = data(idx, NameRole);
    row["email"] = data(idx, EmailRole);
    row["phone"] = data(idx, PhoneRole);
    row["role"] = data(idx, RoleRole);
    row["joined"] = data(idx, JoinedRole);
    row["active"] = data(idx, ActiveRole);
    return row;
}

QVariantMap UserListModel::byId(const QString &userId) const
{
    return at(indexOfId(userId));
}
