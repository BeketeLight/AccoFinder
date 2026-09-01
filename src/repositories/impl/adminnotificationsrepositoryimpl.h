#ifndef ADMINNOTIFICATIONSREPOSITORYIMPL_H
#define ADMINNOTIFICATIONSREPOSITORYIMPL_H

#include <QVariantList>
#include <QJsonObject>
#include "repositories/interfaces/IAdminNotificationsRepository.h"

class AdminNotificationsRepositoryImpl : public IAdminNotificationsRepository
{
    Q_OBJECT
public:
    explicit AdminNotificationsRepositoryImpl(QObject *parent = nullptr);

    void fetchAnnouncementHistory() override;
    void sendAnnouncement(const QString& code,
                          const QString& title,
                          const QString& message) override;

signals:
    void historyFetched(const QVariantList& announcements);
    void announcementSent();
    void fetchError(const QString& error);
    void sendError(const QString& error);
};

#endif // ADMINNOTIFICATIONSREPOSITORYIMPL_H