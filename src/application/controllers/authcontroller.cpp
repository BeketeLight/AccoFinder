#include "authcontroller.h"

AuthController::AuthController(QObject *parent)
    : QObject(parent),
      m_userRepository(new UserRepositoryImpl(this))
{
    connect(m_userRepository, &UserRepositoryImpl::signInSucceded, this, &AuthController::signInSucceded);
    connect(m_userRepository, &UserRepositoryImpl::signInFailed, this, &AuthController::signInFailed);
    connect(m_userRepository, &UserRepositoryImpl::signUpSucceded, this, &AuthController::signUpSucceded);
    connect(m_userRepository, &UserRepositoryImpl::signUpFailed, this, &AuthController::signUpFailed);
    connect(m_userRepository, &UserRepositoryImpl::logOutSucceded, this, &AuthController::userLoggedOut);
}

void AuthController::signIn(const QString &email, const QString &password)
{
    /* what needs to be done
     * 1. check if email and password are not empty
     * 2. if email or password are not availabe emit  a signal signinFailed("email not availabe") or signinFailed("passsword not availabe")
     * 3. if both are available
     * 4. call the signIn function from m_userRepository and pass both email and password
    */
    if (email.isEmpty()) {
        emit signInFailed("email not availabe");
        return;
    }
    if (password.isEmpty()) {
        emit signInFailed("passsword not availabe");
        return;
    }
    Q_ASSERT(m_userRepository);
    m_userRepository->signIn(email, password);
}

void AuthController::signUp(const QString &name, const QString &email, const QString &password, const QString &confirmPassword, const QString &residentialAddress)
{
    /* what needs to be done
     * 1. make sure all function parametrs are available if not wmit signupFaild(missing fieds)
     * 2. compare pass and confirm passwrod ,,if thet dont mactch emit signupfaild(not mtching password)
     * create and regisyer a user by calling the signUp function from m_userRepository
    */
    if (name.isEmpty() || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty() || residentialAddress.isEmpty()) {
        emit signUpFailed("missing fields");
        return;
    }

    if (password != confirmPassword) {
        emit signUpFailed("password and confirmpassword not match");
        return;
    }

    Q_ASSERT(m_userRepository);
    m_userRepository->signUp(name, email, password, confirmPassword, residentialAddress);
}

void AuthController::logOut()
{
    /* what needs to be done
     * call logout function from m_userRepository and emita signal userLoggedout()
    */
    Q_ASSERT(m_userRepository);
    m_userRepository->logOut();
}
