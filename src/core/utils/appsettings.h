#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QSettings>
#include <QColor>

#if defined(Q_OS_ANDROID)
#include <QJniObject>
#include <QJniEnvironment>
#include <QPermission>
#include <QImage>
#endif

#include <QCoreApplication>

class AppSettings : public QObject
{
    Q_OBJECT

public:
    explicit AppSettings(QObject *parent = nullptr);
    static AppSettings& instance();

    Q_INVOKABLE void setStatusBarAppearance(const QColor &backgroundColor, bool darkIcons);

    // =========================
    // AUTH
    // =========================
    Q_INVOKABLE void setToken(const QString &value);
    Q_INVOKABLE QString token() const;

    Q_INVOKABLE void setRefreshToken(const QString &value);
    Q_INVOKABLE QString refreshToken() const;

    Q_INVOKABLE void setUserId(const QString &value);
    Q_INVOKABLE QString userId() const;

    Q_INVOKABLE void setUserType(const QString &value);
    Q_INVOKABLE QString userType() const;

    Q_INVOKABLE void setIsLoggedIn(bool value);
    Q_INVOKABLE bool isLoggedIn() const;

    // =========================
    // USER
    // =========================
    Q_INVOKABLE void setUserName(const QString &value);
    Q_INVOKABLE QString userName() const;

    Q_INVOKABLE void setEmail(const QString &value);
    Q_INVOKABLE QString email() const;

    Q_INVOKABLE void setPhone(const QString &value);
    Q_INVOKABLE QString phone() const;

    // =========================
    // CLIENT
    // =========================
    Q_INVOKABLE void setIsStudent(bool value);
    Q_INVOKABLE bool isStudent() const;

    Q_INVOKABLE void setPreferredLocation(const QString &value);
    Q_INVOKABLE QString preferredLocation() const;

    Q_INVOKABLE void setBudgetMin(double value);
    Q_INVOKABLE double budgetMin() const;

    Q_INVOKABLE void setBudgetMax(double value);
    Q_INVOKABLE double budgetMax() const;

    // =========================
    // AGENT
    // =========================
    Q_INVOKABLE void setEmployeeId(const QString &value);
    Q_INVOKABLE QString employeeId() const;

    Q_INVOKABLE void setAssignedArea(const QString &value);
    Q_INVOKABLE QString assignedArea() const;

    Q_INVOKABLE void setCommissionRate(double value);
    Q_INVOKABLE double commissionRate() const;

    Q_INVOKABLE void setAgentActive(bool value);
    Q_INVOKABLE bool agentActive() const;

    // =========================
    // LANDLORD
    // =========================
    Q_INVOKABLE void setLandlordId(const QString &value);
    Q_INVOKABLE QString landlordId() const;

    Q_INVOKABLE void setLandlordName(const QString &value);
    Q_INVOKABLE QString landlordName() const;

    Q_INVOKABLE void setLandlordPhone(const QString &value);
    Q_INVOKABLE QString landlordPhone() const;

    // =========================
    // APP
    // =========================
    Q_INVOKABLE void setTheme(const QString &value);
    Q_INVOKABLE QString theme() const;

    Q_INVOKABLE void setLanguage(const QString &value);
    Q_INVOKABLE QString language() const;

    Q_INVOKABLE void setFirstLaunch(bool value);
    Q_INVOKABLE bool firstLaunch() const;

    Q_INVOKABLE void setRememberLogin(bool value);
    Q_INVOKABLE bool rememberLogin() const;

    // =========================
    // FILTERS
    // =========================
    Q_INVOKABLE void setFilterLocation(const QString &value);
    Q_INVOKABLE QString filterLocation() const;

    Q_INVOKABLE void setMinPrice(double value);
    Q_INVOKABLE double minPrice() const;

    Q_INVOKABLE void setMaxPrice(double value);
    Q_INVOKABLE double maxPrice() const;

    Q_INVOKABLE void setPropertyType(const QString &value);
    Q_INVOKABLE QString propertyType() const;

    Q_INVOKABLE void setSortOrder(const QString &value);
    Q_INVOKABLE QString sortOrder() const;

    // =========================
    // FAVORITES
    // =========================
    Q_INVOKABLE void setFavoritePropertyIds(const QStringList &value);
    Q_INVOKABLE QStringList favoritePropertyIds() const;

    // =========================
    // NOTIFICATIONS
    // =========================
    Q_INVOKABLE void setNotificationsEnabled(bool value);
    Q_INVOKABLE bool notificationsEnabled() const;

    Q_INVOKABLE void setBookingNotifications(bool value);
    Q_INVOKABLE bool bookingNotifications() const;

    Q_INVOKABLE void setPromotionNotifications(bool value);
    Q_INVOKABLE bool promotionNotifications() const;

    Q_INVOKABLE void setSystemNotifications(bool value);
    Q_INVOKABLE bool systemNotifications() const;

    // =========================
    // RECENT
    // =========================
    Q_INVOKABLE void setRecentPropertyId(const QString &value);
    Q_INVOKABLE QString recentPropertyId() const;

    Q_INVOKABLE void setRecentRoomId(const QString &value);
    Q_INVOKABLE QString recentRoomId() const;

signals:

private:
    QSettings m_settings;
};

#endif // APPSETTINGS_H