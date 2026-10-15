#ifndef ISETTINGSREPOSITORY_H
#define ISETTINGSREPOSITORY_H

#include <QObject>

class ISettingsRepository : public QObject
{
    Q_OBJECT
public:
    explicit ISettingsRepository(QObject *parent = nullptr)
        : QObject(parent) {}

    virtual void fetchPlatformSettings() = 0;
    virtual void updatePlatformSettings(double bookingFee, double commissionRate) = 0;

    virtual ~ISettingsRepository() {}
};

#endif // ISETTINGSREPOSITORY_H
