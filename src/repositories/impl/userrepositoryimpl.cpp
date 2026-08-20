#include "userrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonValue>
#include "services/apiclient.h"
#include "core/utils/appsettings.h"  //for persistence

UserRepositoryImpl::UserRepositoryImpl(QObject *parent)
    :IUserRepository(parent)
{

}
void UserRepositoryImpl::signIn(
    const QString& email,
    const QString& password)
{
    QJsonObject payload;
    payload["email"] = email;
    payload["password"] = password;

    APIClient::instance().post(
        "/auth/login",
        payload,
        [this, email](bool success,
                      const QJsonObject& response)
        {
            if(success){
                QJsonObject data = response["data"].toObject();

                // Parse user fields from backend
                QString userId = data["_id"].toString();
                QString fullName = data["firstName"].toString() + " " + data["surname"].toString();
                QString userEmail = data["email"].toString();
                QString residentialAddress = data["residentialAddress"].toString();
                QString role = data["role"].toString();

                // Parse tokens
                QString accessToken = data["accessToken"].toString();
                QString refreshToken = data["refreshToken"].toString();

                // Use the new constructor
                User* user = new User(
                    userId,
                    fullName,
                    userEmail,
                    residentialAddress,
                    role,
                    this
                    );

                // Persist data
                AppSettings::instance().setToken(accessToken);
                AppSettings::instance().setRefreshToken(refreshToken);
                AppSettings::instance().setUserId(userId);
                AppSettings::instance().setUserType(role);
                AppSettings::instance().setIsLoggedIn(true);
                AppSettings::instance().setUserName(fullName);
                AppSettings::instance().setEmail(userEmail);
                AppSettings::instance().setPreferredLocation(residentialAddress);
                AppSettings::instance().setFilterLocation(residentialAddress);

                emit signInSucceded(user);
            }
            else{
                // Extract error message from various possible locations
                QString error = response["message"].toString();
                if (error.isEmpty())
                    error = response["error"].toString();
                if (error.isEmpty())
                    error = "Login failed. Please check your credentials.";

                // Debug logging to see what's actually being returned
                qDebug() << "Login error received:" << error;
                qDebug() << "Full response:" << response;

                // Check for email not verified - case insensitive and handles trimmed spaces
                QString errorLower = error.trimmed().toLower();
                if (errorLower.contains("email not verified") ||
                    errorLower.contains("not verified")) {
                    qDebug() << "=== EMAIL NOT VERIFIED DETECTED ===";
                    qDebug() << "Email:" << email;
                    qDebug() << "Emitting emailVerificationRequired signal";
                    emit emailVerificationRequired(email);
                    return;
                }

                emit signInFailed(error);
            }
        }, true);
}
void UserRepositoryImpl::signUp(
    const QString& firstName,
    const QString& lastName,
    const QString& email,
    const QString& phone,
    const QString& password,
    const QString& confirmPassword,
    const QString& residentialAddress)
{
    QJsonObject payload;
    payload["firstName"] = firstName;
    payload["surname"] = lastName;
    payload["email"] = email;
    payload["phone"] = phone;
    payload["password"] = password;
    payload["confirmPassword"] = confirmPassword;
    payload["residentialAddress"] = residentialAddress;

    APIClient::instance().post(
        "/auth/register",
        payload,
        [this, phone, residentialAddress](bool success,
                                          const QJsonObject& response)
        {
            if(success){
                QJsonObject data = response["data"].toObject();

                QString userId = data["_id"].toString();
                QString fullName = data["name"].toString();
                QString userEmail = data["email"].toString();
                QString userPhone = data["phone"].toString();
                QString address = data["residentialAddress"].toString();
                QString role = data["role"].toString();

                // Use the new constructor
                User* user = new User(
                    userId,
                    fullName,          // Backend sends single 'name' field
                    userEmail,
                    address,
                    role,
                    this
                    );

                // Persist data
                AppSettings::instance().setUserName(fullName);
                AppSettings::instance().setEmail(userEmail);
                AppSettings::instance().setPhone(userPhone.isEmpty() ? phone : userPhone);

                QString area = address.isEmpty() ? residentialAddress : address;
                AppSettings::instance().setPreferredLocation(area);
                AppSettings::instance().setFilterLocation(area);

                emit signUpSucceded(user);
            }
            else{
                QString error = response["message"].toString();
                if(error.isEmpty())
                    error = response["error"].toString();
                if(error.isEmpty())
                    error = "Registration failed. Please try again.";
                emit signUpFailed(error);
            }
        }, true);
}
void UserRepositoryImpl::logOut()
{
    APIClient::instance().post(
        "/auth/logout",
        QJsonObject(),
        [this](bool success,
               const QJsonObject& response)
        {

            if(success){
                // === CLEARING USER DATA AFTER LOGOUT ===
                AppSettings::instance().setToken("");
                AppSettings::instance().setRefreshToken("");
                AppSettings::instance().setUserId("");
                AppSettings::instance().setUserType("");
                AppSettings::instance().setIsLoggedIn(false);

                emit logOutSucceded();
            }

        }, false);
}

void UserRepositoryImpl::requestOtp(const QString &email, const QString &purpose)
{
    QJsonObject payload;
    payload["email"] = email;
    payload["purpose"] = purpose;

    APIClient::instance().post(
        "/auth/otp/request",
        payload,
        [this](bool success, const QJsonObject &)
        {
            emit otpRequested(success);
        }, true);
}

void UserRepositoryImpl::verifyOtp(const QString &email,
                                   const QString &code,
                                   const QString &purpose)
{
    QJsonObject payload;
    payload["email"] = email;
    payload["code"] = code;
    payload["purpose"] = purpose;

    APIClient::instance().post(
        "/auth/otp/verify",
        payload,
        [this](bool success, const QJsonObject &)
        {
            emit otpVerified(success);
        }, true);
}

void UserRepositoryImpl::checkAccount(const QString &email)
{
    APIClient::instance().get(  // Use GET
        "/auth/check-email?email=" + email,  // Query parameter
        [this](bool success,
               const QJsonObject& response)
        {
            if (success) {
                bool exists = response["exists"].toBool(false);
                emit accountChecked(exists);
            } else {
                emit accountChecked(false);
            }
        }, true);
}


