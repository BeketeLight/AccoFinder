#include "authcontroller.h"

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
    connect(m_userRepository, &UserRepositoryImpl::emailVerified, this,
            [this, stopLoading](const bool& status) {
        stopLoading();
        emit emailVerified(status);
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
                            const QString &password,
                            const QString &confirmPassword,
                            const QString &residentialAddress)
{
    if (fistName.trimmed().isEmpty()
        || lastName.trimmed().isEmpty()
        || email.trimmed().isEmpty()
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
        password,
        confirmPassword,
        residentialAddress.trimmed());
}

void AuthController::logOut()
{
    setLoading(true);
    m_userRepository->logOut();
}

void AuthController::verifyEmail(const QString &email)
{
    if (email.trimmed().isEmpty()) {
        emit emailVerified(false);
        return;
    }

    setLoading(true);
    m_userRepository->verifyEmail(email.trimmed());
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
