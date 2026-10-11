#include "settingscontroller.h"
#include "core/utils/appsettings.h"

SettingsController::SettingsController(QObject *parent)
    : QObject{parent},
    m_settingsRepository(new SettingsRepositoryImpl(this))
{
    connect(m_settingsRepository, &SettingsRepositoryImpl::platformSettingsLoaded,
            this, [this](double bookingFee, double commissionRate) {
        // Single source of truth: everything downstream (checkout, admin
        // display) reads the settings from AppSettings, never from the network.
        AppSettings::instance().setBookingFee(bookingFee);
        AppSettings::instance().setPlatformCommissionRate(commissionRate);
        emit platformSettingsLoaded(bookingFee, commissionRate);
    });

    connect(m_settingsRepository, &SettingsRepositoryImpl::platformSettingsUpdated,
            this, [this](double bookingFee, double commissionRate) {
        AppSettings::instance().setBookingFee(bookingFee);
        AppSettings::instance().setPlatformCommissionRate(commissionRate);
        emit platformSettingsUpdated(bookingFee, commissionRate);
    });

    connect(m_settingsRepository, &SettingsRepositoryImpl::settingsError,
            this, &SettingsController::settingsError);
}

void SettingsController::fetchPlatformSettings()
{
    m_settingsRepository->fetchPlatformSettings();
}

void SettingsController::updatePlatformSettings(double bookingFee, double commissionRate)
{
    m_settingsRepository->updatePlatformSettings(bookingFee, commissionRate);
}