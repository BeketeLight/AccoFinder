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
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setNotifications(QList<Notification *> notifications);

signals:
    void countChanged(int newCount);

private:
    QVector<QSharedPointer<Notification>> m_notifications;
};

#endif // NOTIFICATIONLISTMODEL_H
