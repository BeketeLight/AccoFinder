#include "appsettings.h"

AppSettings::AppSettings(QObject *parent)
    : QObject{parent},
    m_settings(QCoreApplication::organizationName(),
               QCoreApplication::applicationName())
{}

// SINGLETON

AppSettings &AppSettings::instance()
{
    static AppSettings appSettings;
    return appSettings;
}

// ANDROID STATUS BAR (UNCHANGED)

void AppSettings::setStatusBarAppearance(const QColor &backgroundColor, bool darkIcons)
{
#if defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() -> QVariant {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (!activity.isValid()) {
            qWarning() << "setStatusBarAppearance: No valid Android activity";
            return QVariant(false);
        }

        QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
        if (!window.isValid()) {
            qWarning() << "setStatusBarAppearance: No valid window";
            return QVariant(false);
        }

        jint sdkVersion = QJniObject::getStaticField<jint>("android/os/Build$VERSION", "SDK_INT");

        window.callMethod<void>("addFlags", "(I)V", 0x80000000);
        window.callMethod<void>("clearFlags", "(I)V", 0x04000000);

        jint statusColor = backgroundColor.alpha() << 24 |
                           backgroundColor.red()   << 16 |
                           backgroundColor.green() << 8  |
                           backgroundColor.blue();

        window.callMethod<void>("setStatusBarColor", "(I)V", statusColor);

        if (sdkVersion >= 30) {
            QJniObject controller = window.callObjectMethod(
                "getInsetsController",
                "()Landroid/view/WindowInsetsController;");

            if (controller.isValid()) {
                jint appearance = darkIcons ? 0x00000008 : 0x00000000;
                controller.callMethod<void>(
                    "setSystemBarsAppearance",
                    "(II)V",
                    appearance,
                    0x00000008);
            }
        }

        if (sdkVersion >= 23 && sdkVersion < 30) {
            QJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
            if (decorView.isValid()) {
                jint uiFlags = decorView.callMethod<jint>("getSystemUiVisibility", "()I");
                if (darkIcons)
                    uiFlags |= 0x00002000;
                else
                    uiFlags &= ~0x00002000;

                decorView.callMethod<void>("setSystemUiVisibility", "(I)V", uiFlags);
            }
        }

        return QVariant(true);
    }).waitForFinished();
#else
    Q_UNUSED(backgroundColor);
    Q_UNUSED(darkIcons);
#endif
}

// AUTH

void AppSettings::setToken(const QString &value) {
    m_settings.setValue("auth/token", value);
}
QString AppSettings::token() const {
    return m_settings.value("auth/token").toString();
}

void AppSettings::setRefreshToken(const QString &value) {
    m_settings.setValue("auth/refreshToken", value);
}
QString AppSettings::refreshToken() const {
    return m_settings.value("auth/refreshToken").toString();
}

void AppSettings::setUserId(const QString &value) {
    m_settings.setValue("auth/userId", value);
}
QString AppSettings::userId() const {
    return m_settings.value("auth/userId").toString();
}

void AppSettings::setUserType(const QString &value) {
    m_settings.setValue("auth/userType", value);
}
QString AppSettings::userType() const {
    return m_settings.value("auth/userType").toString();
}

void AppSettings::setIsLoggedIn(bool value) {
    m_settings.setValue("auth/isLoggedIn", value);
}
bool AppSettings::isLoggedIn() const {
    return m_settings.value("auth/isLoggedIn", false).toBool();
}

// USER

void AppSettings::setUserName(const QString &value) {
    m_settings.setValue("user/name", value);
}
QString AppSettings::userName() const {
    return m_settings.value("user/name").toString();
}

void AppSettings::setEmail(const QString &value) {
    m_settings.setValue("user/email", value);
}
QString AppSettings::email() const {
    return m_settings.value("user/email").toString();
}

void AppSettings::setPhone(const QString &value) {
    m_settings.setValue("user/phone", value);
}
QString AppSettings::phone() const {
    return m_settings.value("user/phone").toString();
}

// CLIENT

void AppSettings::setIsStudent(bool value) {
    m_settings.setValue("client/isStudent", value);
}
bool AppSettings::isStudent() const {
    return m_settings.value("client/isStudent", false).toBool();
}

void AppSettings::setPreferredLocation(const QString &value) {
    m_settings.setValue("client/preferredLocation", value);
}
QString AppSettings::preferredLocation() const {
    return m_settings.value("client/preferredLocation").toString();
}

void AppSettings::setBudgetMin(double value) {
    m_settings.setValue("client/budgetMin", value);
}
double AppSettings::budgetMin() const {
    return m_settings.value("client/budgetMin", 0.0).toDouble();
}

void AppSettings::setBudgetMax(double value) {
    m_settings.setValue("client/budgetMax", value);
}
double AppSettings::budgetMax() const {
    return m_settings.value("client/budgetMax", 0.0).toDouble();
}

// AGENT

void AppSettings::setEmployeeId(const QString &value) {
    m_settings.setValue("agent/employeeId", value);
}
QString AppSettings::employeeId() const {
    return m_settings.value("agent/employeeId").toString();
}

void AppSettings::setAssignedArea(const QString &value) {
    m_settings.setValue("agent/assignedArea", value);
}
QString AppSettings::assignedArea() const {
    return m_settings.value("agent/assignedArea").toString();
}

void AppSettings::setCommissionRate(double value) {
    m_settings.setValue("agent/commissionRate", value);
}
double AppSettings::commissionRate() const {
    return m_settings.value("agent/commissionRate", 0.0).toDouble();
}

void AppSettings::setAgentActive(bool value) {
    m_settings.setValue("agent/isActive", value);
}
bool AppSettings::agentActive() const {
    return m_settings.value("agent/isActive", false).toBool();
}

// LANDLORD

void AppSettings::setLandlordId(const QString &value) {
    m_settings.setValue("landlord/id", value);
}
QString AppSettings::landlordId() const {
    return m_settings.value("landlord/id").toString();
}

void AppSettings::setLandlordName(const QString &value) {
    m_settings.setValue("landlord/name", value);
}
QString AppSettings::landlordName() const {
    return m_settings.value("landlord/name").toString();
}

void AppSettings::setLandlordPhone(const QString &value) {
    m_settings.setValue("landlord/phone", value);
}
QString AppSettings::landlordPhone() const {
    return m_settings.value("landlord/phone").toString();
}

// APP

void AppSettings::setTheme(const QString &value) {
    m_settings.setValue("app/theme", value);
}
QString AppSettings::theme() const {
    return m_settings.value("app/theme", "System").toString();
}

void AppSettings::setLanguage(const QString &value) {
    m_settings.setValue("app/language", value);
}
QString AppSettings::language() const {
    return m_settings.value("app/language", "en").toString();
}

void AppSettings::setFirstLaunch(bool value) {
    m_settings.setValue("app/firstLaunch", value);
}
bool AppSettings::firstLaunch() const {
    return m_settings.value("app/firstLaunch", true).toBool();
}

void AppSettings::setRememberLogin(bool value) {
    m_settings.setValue("app/rememberLogin", value);
}
bool AppSettings::rememberLogin() const {
    return m_settings.value("app/rememberLogin", true).toBool();
}

// FILTERS

void AppSettings::setFilterLocation(const QString &value) {
    m_settings.setValue("filters/location", value);
}
QString AppSettings::filterLocation() const {
    return m_settings.value("filters/location").toString();
}

void AppSettings::setMinPrice(double value) {
    m_settings.setValue("filters/minPrice", value);
}
double AppSettings::minPrice() const {
    return m_settings.value("filters/minPrice", 0.0).toDouble();
}

void AppSettings::setMaxPrice(double value) {
    m_settings.setValue("filters/maxPrice", value);
}
double AppSettings::maxPrice() const {
    return m_settings.value("filters/maxPrice", 0.0).toDouble();
}

void AppSettings::setPropertyType(const QString &value) {
    m_settings.setValue("filters/propertyType", value);
}
QString AppSettings::propertyType() const {
    return m_settings.value("filters/propertyType").toString();
}

void AppSettings::setSortOrder(const QString &value) {
    m_settings.setValue("filters/sortOrder", value);
}
QString AppSettings::sortOrder() const {
    return m_settings.value("filters/sortOrder").toString();
}

// FAVORITES

void AppSettings::setFavoritePropertyIds(const QStringList &value) {
    m_settings.setValue("favorites/propertyIds", value);
}
QStringList AppSettings::favoritePropertyIds() const {
    return m_settings.value("favorites/propertyIds").toStringList();
}

// NOTIFICATIONS

void AppSettings::setNotificationsEnabled(bool value) {
    m_settings.setValue("notifications/enabled", value);
}
bool AppSettings::notificationsEnabled() const {
    return m_settings.value("notifications/enabled", true).toBool();
}

void AppSettings::setBookingNotifications(bool value) {
    m_settings.setValue("notifications/bookings", value);
}
bool AppSettings::bookingNotifications() const {
    return m_settings.value("notifications/bookings", true).toBool();
}

void AppSettings::setPromotionNotifications(bool value) {
    m_settings.setValue("notifications/promotions", value);
}
bool AppSettings::promotionNotifications() const {
    return m_settings.value("notifications/promotions", true).toBool();
}

void AppSettings::setSystemNotifications(bool value) {
    m_settings.setValue("notifications/system", value);
}
bool AppSettings::systemNotifications() const {
    return m_settings.value("notifications/system", true).toBool();
}

// RECENT

void AppSettings::setRecentPropertyId(const QString &value) {
    m_settings.setValue("recent/propertyId", value);
}
QString AppSettings::recentPropertyId() const {
    return m_settings.value("recent/propertyId").toString();
}

void AppSettings::setRecentRoomId(const QString &value) {
    m_settings.setValue("recent/roomId", value);
}
QString AppSettings::recentRoomId() const {
    return m_settings.value("recent/roomId").toString();
}