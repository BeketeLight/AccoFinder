#include "notificationlistmodel.h"

NotificationListModel::NotificationListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int NotificationListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_notifications.size();
}

int NotificationListModel::unreadCount() const
{
    int count = 0;
    for (const auto &n : m_notifications) {
        const QString s = n->status().toUpper();
        if (s != "READ" && s != "READY")
            ++count;
    }
    return count;
}

QVariant NotificationListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_notifications.size())
        return QVariant();

    Notification *n = m_notifications.at(index.row()).data();
    switch (role) {
    case IdRole:
        return n->getId();
    case TitleRole:
        return n->getType();
    case MessageRole:
        return n->getMessage();
    case UnreadRole: {
        // A notification is unread unless it carries a status of "READ"/"read".
        const QString s = n->status().toUpper();
        return s != "READ" && s != "READY";
    }
    }

    return QVariant();
}

QHash<int, QByteArray> NotificationListModel::roleNames() const
{
    static QHash<int, QByteArray> roles {
        { IdRole, "id" },
        { TitleRole, "title" },
        { MessageRole, "message" },
        { UnreadRole, "unread" }
    };
    return roles;
}

void NotificationListModel::setNotifications(QList<Notification *> notifications)
{
    beginResetModel();
    m_notifications.clear();
    for (Notification *n : notifications)
        m_notifications.append(QSharedPointer<Notification>(n));
    endResetModel();
    emit countChanged(m_notifications.size());
    emit unreadCountChanged(unreadCount());
}
