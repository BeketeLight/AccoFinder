#include "adminnotificationsviewmodel.h"
#include <QVariantList>

AdminNotificationsViewModel::AdminNotificationsViewModel(QObject *parent)
    : QObject(parent),
      m_repository(new AdminNotificationsRepositoryImpl(this)),
      m_history(new PaymentsListModel(this))
{
    connect(m_repository, &AdminNotificationsRepositoryImpl::historyFetched,
            this, [this](const QVariantList& announcements) {
        applyHistory(announcements);
        setLoading(false);
        emit historyChanged();
    });

    connect(m_repository, &AdminNotificationsRepositoryImpl::announcementSent,
            this, [this]() {
        refresh();
    });

    connect(m_repository, &AdminNotificationsRepositoryImpl::fetchError,
            this, [this](const QString& error) {
        setLoading(false);
        emit errorOccurred(error);
    });

    connect(m_repository, &AdminNotificationsRepositoryImpl::sendError,
            this, [this](const QString& error) {
        emit errorOccurred(error);
    });
}

void AdminNotificationsViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void AdminNotificationsViewModel::applyHistory(const QVariantList& announcements)
{
    QVector<QVariantMap> rows;
    for (const QVariant& item : announcements)
        rows.append(item.toMap());
    m_history->setRows(rows);
}

void AdminNotificationsViewModel::refresh()
{
    setLoading(true);
    m_repository->fetchAnnouncementHistory();
}

void AdminNotificationsViewModel::sendAnnouncement(
    const QString& code, const QString& title, const QString& message)
{
    m_repository->sendAnnouncement(code, title, message);
}