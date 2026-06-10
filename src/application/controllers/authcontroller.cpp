#include "authcontroller.h"

AuthController::AuthController(QObject *parent)
    :QObject(parent)
{
}

void AuthController::signIn(QString &email, QString &password)
{
    /* what needs to be done
     * 1. check if email and password are not empty
     * 2. if email or password are not availabe emit  a signal signinFailed("email not availabe") or signinFailed("passsword not availabe")
     * 3. if both are available
     * 4. call the signIn function from m_userRepository and pass both email and password
    */

    
}

void AuthController::signUp(const QString &name, const QString &email, const QString &password, const QString &confirmPassword, const QString &residentialAddress)
{
    /* what needs to be done
     * 1. make sure all function parametrs are available if not wmit signupFaild(missing fieds)
     * 2. compare pass and confirm passwrod ,,if thet dont mactch emit signupfaild(not mtching password)
     * create and regisyer a user by calling the signUp function from m_userRepository
    */
    
}

void AuthController::logOut()
{
    /* what needs to be done
     * call logout function from m_userRepository and emita signal userLoggedout()
    */
    
}
