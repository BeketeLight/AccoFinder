#ifndef USERVIEWMODEL_H
#define USERVIEWMODEL_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include "application/controllers/usercontroller.h"
#include "presentation/models/userlistmodel.h"

class UserViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(UserListModel* userListModel READ userListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit UserViewModel(QObject *parent = nullptr);

    UserListModel* userListModel() const { return m_userListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getUsers();
    Q_INVOKABLE void updateRole(const QString& userId, const QString& role);
    Q_INVOKABLE void setActive(const QString& userId, bool active);
    Q_INVOKABLE void addUser(const QString& firstName,
                             const QString& lastName,
                             const QString& email,
                             const QString& phone,
                             const QString& role,
                             const QString& residentialAddress);
    Q_INVOKABLE QVariantMap findUserByEmail(const QString& email) const;

    Q_INVOKABLE int activeCount() const;
    Q_INVOKABLE int suspendedCount() const;

private:
    int m_index = -1;
    bool m_isLoading = false;
    UserListModel* m_userListModel = nullptr;
    UserController* m_userController = nullptr;

    void setLoading(bool loading);

private slots:
    void onUsersLoaded(QList<User*>& users);
    void onUserUpdated(User* user);
    void onUserError(const QString& error);

signals:
    void isLoadingChanged(bool isLoading);
    void userError(const QString& error);
    void userAdded(const QString& email);
};

#endif // USERVIEWMODEL_H
