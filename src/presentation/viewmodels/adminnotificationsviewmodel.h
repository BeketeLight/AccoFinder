#ifndef ADMINNOTIFICATIONSVIEWMODEL_H
#define ADMINNOTIFICATIONSVIEWMODEL_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include "repositories/impl/adminnotificationsrepositoryimpl.h"
#include "presentation/models/paymentslistmodel.h"

class AdminNotificationsViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PaymentsListModel* notificationsModel READ notificationsModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit AdminNotificationsViewModel(QObject *parent = nullptr);

    PaymentsListModel* notificationsModel() const { return m_history; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void sendAnnouncement(const QString& code,
                                      const QString& title,
                                      const QString& message);

private:
    AdminNotificationsRepositoryImpl* m_repository = nullptr;
    PaymentsListModel* m_history = nullptr;

    bool m_isLoading = false;

    void setLoading(bool loading);
    void applyHistory(const QVariantList& announcements);

signals:
    void isLoadingChanged(bool isLoading);
    void historyChanged();
    void errorOccurred(const QString& error);
};

#endif // ADMINNOTIFICATIONSVIEWMODEL_H