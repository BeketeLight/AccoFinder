#ifndef USERLISTMODEL_H
#define USERLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QList>
#include <QHash>
#include <QByteArray>
#include <QVariantMap>
#include "models/user.h"

class UserListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        EmailRole,
        PhoneRole,
        RoleRole,
        JoinedRole,
        ActiveRole
    };

    explicit UserListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const { return m_users.size(); }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setUsers(QList<User*> users);
    void addUser(User* user);
    void updateUser(int index, User* user);
    void updateUserById(const QString& userId, User* user);
    int indexOfId(const QString& userId) const;

    Q_INVOKABLE int size() const { return m_users.size(); }
    Q_INVOKABLE QVariantMap at(int index) const;
    Q_INVOKABLE QVariantMap byId(const QString& userId) const;

signals:
    void countChanged(int newCount);

private:
    QVector<User*> m_users;
};

#endif // USERLISTMODEL_H
