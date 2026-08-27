#ifndef DRAFTVIEWMODEL_H
#define DRAFTVIEWMODEL_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>

class PropertyViewModel;

/**
 * Durable, device-local storage of unsent property drafts.
 *
 * Drafts are kept as JSON in QSettings so they survive an app restart / device
 * reboot. This lets the user close AccoFinder after a failed upload and return
 * to the list of saved drafts later to resend them.
 *
 * A draft is a flat property payload mirroring the backend create schema
 * (title, description, price, propertyType, physicalAddress, amenities,
 * landlord, landlordPhone, verificationStatus, isActive, rooms[], photos[]).
 * Each draft is stored under a stable key (timestamp-based).
 */
class DraftViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY draftsChanged)
public:
    explicit DraftViewModel(PropertyViewModel *propertyViewModel = nullptr,
                            QObject *parent = nullptr);

    int count() const;

    // ---- storage ----
    Q_INVOKABLE QString saveDraft(const QJsonObject &payload);
    Q_INVOKABLE void removeDraft(const QString &key);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE QJsonObject getDraft(const QString &key) const;
    Q_INVOKABLE QStringList keys() const;
    Q_INVOKABLE QJsonObject allDrafts() const;
    Q_INVOKABLE bool updateDraft(const QString &key, const QJsonObject &payload);

    // ---- resend ----
    Q_INVOKABLE bool resendDraft(const QString &key);

signals:
    void draftsChanged();

private slots:
    void onPropertyCreated(const QString &id, const QString &title);
    void onPropertyFailed(const QString &error);

private:
    PropertyViewModel *m_propertyViewModel = nullptr;
    QString m_resendingKey;
    QJsonObject m_cache;

    QJsonObject loadCache() const;
    void persist();
};

#endif // DRAFTVIEWMODEL_H
