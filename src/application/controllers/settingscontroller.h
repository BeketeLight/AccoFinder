#ifndef SETTINGSCONTROLLER_H
#define SETTINGSCONTROLLER_H

#include <QObject>
#include "repositories/impl/settingsrepositoryimpl.h"

class SettingsController : public QObject
{
    Q_OBJECT
public:
    explicit SettingsController(QObject *parent = nullptr);

    // Fetches the admin-controlled platform settings from the API and caches
    // the booking fee in AppSettings so the booking screen reads it locally.
    // Called once at startup and available to QML on demand.
    Q_INVOKABLE void fetchPlatformSettings();
    Q_INVOKABLE void updatePlatformSettings(double bookingFee, double commissionRate);

signals:
    void platformSettingsLoaded(double bookingFee, double commissionRate);
    void platformSettingsUpdated(double bookingFee, double commissionRate);
    void settingsError(const QString& error);

private:
    SettingsRepositoryImpl* m_settingsRepository;
};

#endif // SETTINGSCONTROLLER_H
