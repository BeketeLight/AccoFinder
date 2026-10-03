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

    Q_INVOKABLE void setBankName(const QString &value);
    Q_INVOKABLE QString bankName() const;

    Q_INVOKABLE void setBankAccountNumber(const QString &value);
    Q_INVOKABLE QString bankAccountNumber() const;

    Q_INVOKABLE void setPaymentMethod(const QString &value);
    Q_INVOKABLE QString paymentMethod() const;

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

    // =========================
    // REGISTRATION DRAFT
    // =========================
    // A sign-up can stall while the user leaves the app to read the emailed
    // OTP, during which Android may kill the process. The wizard therefore
    // checkpoints what has been typed so a cold start can resume instead of
    // restarting from an empty form. The draft is deliberately short-lived and
    // self-expiring: see registrationDraftTtlMs().
    Q_INVOKABLE void saveRegistrationDraft(const QString &firstName,
                                           const QString &lastName,
                                           const QString &location,
                                           const QString &phone,
                                           const QString &email,
                                           const QString &password,
                                           int step);
    Q_INVOKABLE bool hasRegistrationDraft() const;
    Q_INVOKABLE void clearRegistrationDraft();

    Q_INVOKABLE QString registrationDraftFirstName() const;
    Q_INVOKABLE QString registrationDraftLastName() const;
    Q_INVOKABLE QString registrationDraftLocation() const;
    Q_INVOKABLE QString registrationDraftPhone() const;
    Q_INVOKABLE QString registrationDraftEmail() const;
    Q_INVOKABLE QString registrationDraftPassword() const;
    // Index of the wizard step the user had reached, clamped to a valid step.
    Q_INVOKABLE int registrationDraftStep() const;
    // Seconds left before the draft expires; 0 once it is gone.
    Q_INVOKABLE int registrationDraftSecondsRemaining() const;

    // =========================
    // CAMERA (transient, in-memory)
    // =========================
    // Stores the path of the photo just captured by the full-screen camera
    // page so the caller can pick it up after the page is popped. Not persisted.
    Q_INVOKABLE void setCapturedPhotoPath(const QString &value);
    Q_INVOKABLE QString capturedPhotoPath() const;

signals:
    // Emitted whenever login state, role or user identity changes so that
    // QML views with non-reactive Q_INVOKABLE bindings (e.g. the footer)
    // can refresh themselves.
    void userSessionChanged();

    // Emitted when the camera page stores a freshly captured photo path.
    void capturedPhotoPathChanged();

private:
    // A registration draft is only offered back to the user for this long,
    // so an abandoned sign-up never leaves stale personal details sitting in
    // local storage for a future session to stumble into.
    static constexpr qint64 registrationDraftTtlMs = 10 * 60 * 1000;
    static constexpr int registrationDraftStepCount = 6;

    // True when a draft exists and is still inside its TTL. Expired drafts are
    // purged on the spot so expiry needs no timer or background task.
    bool registrationDraftIsFresh() const;
    // Reads one draft field, or an empty string once the draft has expired.
    QString registrationDraftField(const QString &field) const;

    QSettings m_settings;
    QString m_capturedPhotoPath;
};

#endif // APPSETTINGS_H
