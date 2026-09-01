#ifndef IADMINNOTIFICATIONSREPOSITORY_H
#define IADMINNOTIFICATIONSREPOSITORY_H

#include <QObject>
#include <QString>
#include <QVariantList>

class IAdminNotificationsRepository : public QObject
{
    Q_OBJECT
public:
    explicit IAdminNotificationsRepository(QObject *parent = nullptr)
        : QObject(parent) {}

    virtual void fetchAnnouncementHistory() = 0;
    virtual void sendAnnouncement(const QString& code,
                                  const QString& title,
                                  const QString& message) = 0;

    virtual ~IAdminNotificationsRepository() {}
};

#endif // IADMINNOTIFICATIONSREPOSITORY_H