#ifndef SETTINGSREPOSITORYIMPL_H
#define SETTINGSREPOSITORYIMPL_H

#include "repositories/interfaces/ISettingsRepository.h"

class SettingsRepositoryImpl : public ISettingsRepository
{
    Q_OBJECT
public:
    explicit SettingsRepositoryImpl(QObject *parent = nullptr);

    void fetchPlatformSettings() override;
    void updatePlatformSettings(double bookingFee, double commissionRate) override;

signals:
    void platformSettingsLoaded(double bookingFee, double commissionRate);
    void platformSettingsUpdated(double bookingFee, double commissionRate);
    void settingsError(const QString& error);
};

#endif // SETTINGSREPOSITORYIMPL_H
