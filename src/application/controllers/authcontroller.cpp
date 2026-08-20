#include "authcontroller.h"
#include "core/utils/ERegistrationPurpose.h"

AuthController::AuthController(QObject *parent)
    : QObject(parent)
    , m_userRepository(new UserRepositoryImpl(this))
{
    auto stopLoading = [this]() { setLoading(false); };

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
