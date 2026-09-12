#include "authcontroller.h"
#include "core/utils/ERegistrationPurpose.h"
#include "services/apiclient.h"
#include <QTimer>

AuthController::AuthController(QObject *parent)
    : QObject(parent)
    , m_userRepository(new UserRepositoryImpl(this))
    , m_googleAuthTimeout(new QTimer(this))
{
    // The deep-link redirect account for OAuth terminates the flow (whether
    // it succeeds or fails). A watchdog stops the loading state when the user
    // cancels the browser flow and the redirect never arrives — otherwise the
    // spinner would hang forever until the app is restarted.
    m_googleAuthTimeout->setSingleShot(true);
    m_googleAuthTimeout->setInterval(60000);
    connect(m_googleAuthTimeout, &QTimer::timeout, this, [this]() {
        if (m_googleAuthPending)
            cancelGoogleAuth();
    });

    auto stopLoading = [this]() {
        setLoading(false);
        clearGooglePending();
    };

    connect(m_userRepository, &UserRepositoryImpl::signInSucceded, this,
            [this, stopLoading](User* user) {
        stopLoading();
        emit signInSucceded(user);
    });
    connect(m_userRepository, &UserRepositoryImpl::signInFailed, this,
            [this, stopLoading](const QString& message) {
        stopLoading();
        emit signInFailed(message);
    });
    connect(m_userRepository, &UserRepositoryImpl::emailVerificationRequired, this,
            [this, stopLoading](const QString& email) {
        stopLoading();
        emit emailVerificationRequired(email);
    });
    connect(m_userRepository, &UserRepositoryImpl::accountSuspended, this,
            [this, stopLoading]() {
        stopLoading();
        emit accountSuspended();
    });
    connect(m_userRepository, &UserRepositoryImpl::signUpSucceded, this,
            [this, stopLoading](User* user) {
        stopLoading();
        emit signUpSucceded(user);
    });
    connect(m_userRepository, &UserRepositoryImpl::signUpFailed, this,
            [this, stopLoading](const QString& message) {
        stopLoading();
        emit signUpFailed(message);
    });
    connect(m_userRepository, &UserRepositoryImpl::logOutSucceded, this,
            [this, stopLoading]() {
        stopLoading();
        emit userLoggedOut();
    });
    connect(m_userRepository, &UserRepositoryImpl::otpRequested, this,
            [this, stopLoading](bool status) {
        stopLoading();
        emit otpRequested(status);
    });
    connect(m_userRepository, &UserRepositoryImpl::otpVerified, this,
            [this, stopLoading](bool status) {
        stopLoading();
        emit otpVerified(status);
    });
    connect(m_userRepository, &UserRepositoryImpl::accountChecked, this,
            [this, stopLoading](const bool& status) {
        stopLoading();
        emit accountChecked(status);
    });
    connect(m_userRepository, &UserRepositoryImpl::passwordReset, this,
            [this, stopLoading](bool status) {
        stopLoading();
        emit passwordReset(status);
    });
    connect(m_userRepository, &UserRepositoryImpl::profileFetched, this,
            [this, stopLoading]() {
        stopLoading();
        emit profileFetched();
    });
    connect(m_userRepository, &UserRepositoryImpl::profileFetchFailed, this,
            [this, stopLoading](const QString& error) {
        stopLoading();
        emit profileFetchFailed(error);
    });
    connect(m_userRepository, &UserRepositoryImpl::profileSaved, this,
            [this, stopLoading](bool status) {
        stopLoading();
        emit profileSaved(status);
    });
}

void AuthController::setLoading(bool loading)
{
    if (m_isLoading == loading)
        return;
    m_isLoading = loading;
    emit isLoadingChanged(m_isLoading);
}

void AuthController::signIn(const QString &email, const QString &password)
{
    if (email.trimmed().isEmpty()) {
        emit signInFailed("Email is required.");
        return;
    }
    if (password.isEmpty()) {
        emit signInFailed("Password is required.");
        return;
    }

    setLoading(true);
    m_userRepository->signIn(email.trimmed(), password);
}

void AuthController::signUp(const QString& fistName,
                            const QString& lastName,
                            const QString &email,
                            const QString &phone,
                            const QString &password,
                            const QString &confirmPassword,
                            const QString &residentialAddress)
{
    if (fistName.trimmed().isEmpty()
        || lastName.trimmed().isEmpty()
        || email.trimmed().isEmpty()
        || phone.trimmed().isEmpty()
        || password.isEmpty()
        || confirmPassword.isEmpty()
        || residentialAddress.trimmed().isEmpty()) {
        emit signUpFailed("Please fill in all required fields.");
        return;
    }

    if (password != confirmPassword) {
        emit signUpFailed("Password and confirm password do not match.");
        return;
    }

    setLoading(true);
    m_userRepository->signUp(
        fistName.trimmed(),
        lastName.trimmed(),
        email.trimmed(),
        phone.trimmed(),
        password,
        confirmPassword,
        residentialAddress.trimmed());
}

void AuthController::logOut()
{
    setLoading(true);
    m_userRepository->logOut();
}

void AuthController::requestOtp(const QString &email, const QString &purpose)
{
    if (email.trimmed().isEmpty()) {
        emit otpRequested(false);
        return;
    }

    setLoading(true);
    m_userRepository->requestOtp(
        email.trimmed(),
        normalizeRegistrationPurpose(purpose));
}

void AuthController::verifyOtp(const QString &email,
                               const QString &code,
                               const QString &purpose)
{
    if (email.trimmed().isEmpty() || code.trimmed().isEmpty()) {
        emit otpVerified(false);
        return;
    }

    setLoading(true);
    m_userRepository->verifyOtp(
        email.trimmed(),
        code.trimmed(),
        normalizeRegistrationPurpose(purpose));
}

void AuthController::checkAccount(const QString &email)
{
    if (email.trimmed().isEmpty()) {
        emit accountChecked(false);
        return;
    }

    setLoading(true);
    m_userRepository->checkAccount(email.trimmed());
}

void AuthController::resetPassword(const QString &email, const QString &newPassword)
{
    if (email.trimmed().isEmpty() || newPassword.isEmpty()) {
        emit passwordReset(false);
        return;
    }

    setLoading(true);
    m_userRepository->resetPassword(email.trimmed(), newPassword);
}

QString AuthController::googleAuthUrl() const
{
    // The APIClient's base URL is used so this stays correct across
    // environments (staging / production).
    return APIClient::instance().baseUrl() + "/auth/google";
}

void AuthController::signInWithGoogle(const QString &authUrl)
{
    QString url = authUrl.trimmed().isEmpty()
        ? googleAuthUrl()
        : authUrl;

    m_googleAuthPending = true;
    emit googleAuthPendingChanged(true);
    setLoading(true);
    m_googleAuthTimeout->start();
    m_userRepository->signInWithGoogle(url);
}

void AuthController::handleGoogleAuthUrl(const QString &url)
{
    clearGooglePending();
    setLoading(true);
    m_userRepository->handleGoogleAuthUrl(url);
}

void AuthController::cancelGoogleAuth()
{
    if (!m_googleAuthPending)
        return;
    clearGooglePending();
    setLoading(false);
    emit signInFailed("Google sign in was cancelled or did not complete. Please try again.");
}

void AuthController::clearGooglePending()
{
    if (!m_googleAuthPending)
        return;
    m_googleAuthPending = false;
    if (m_googleAuthTimeout && m_googleAuthTimeout->isActive())
        m_googleAuthTimeout->stop();
    emit googleAuthPendingChanged(false);
}

void AuthController::fetchProfile()
{
    setLoading(true);
    m_userRepository->fetchProfile();
}

void AuthController::saveProfile(const QString &bankName,
                                 const QString &bankAccountNumber,
                                 const QString &paymentMethod)
{
    setLoading(true);
    m_userRepository->saveProfile(bankName, bankAccountNumber, paymentMethod);
}
