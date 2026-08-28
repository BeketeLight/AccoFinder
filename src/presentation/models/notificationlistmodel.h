#ifndef NOTIFICATIONLISTMODEL_H
#define NOTIFICATIONLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QList>
#include <QHash>
#include <QByteArray>
#include <QSharedPointer>
#include "models/notification.h"

class NotificationListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int unreadCount READ unreadCount NOTIFY unreadCountChanged)

public:
    enum roles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        MessageRole,
        UnreadRole
    };

    explicit NotificationListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const { return m_notifications.size(); }
    int unreadCount() const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setNotifications(QList<Notification *> notifications);

signals:
    void countChanged(int newCount);
    void unreadCountChanged(int newCount);

private:
    QVector<QSharedPointer<Notification>> m_notifications;
};

#endif // NOTIFICATIONLISTMODEL_H
