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
    //sending QJsonObject to the server
    QJsonObject payload;
    payload["email"] = email;   
    payload["password"] = password;

    APIClient::instance().post(
        "/auth/login",
        payload,
        [this](bool success, 
            const QJsonObject& response)
        {
         
        if(success){
            User* user = new User(
                response["id"].toString(),
                response["firstName"].toString(),
                response["lastName"].toString(),
                response["email"].toString(),
                response["phone"].toString(),
                QDateTime::fromString(response["createdAt"].toString(), Qt::ISODate),
                this
            );

            //====PERSIST LOGGED IN USER DATA==
            AppSettings::instance().setToken(response.value("token").toString());
            AppSettings::instance().setRefreshToken(response.value("refreshToken").toString());
            AppSettings::instance().setUserId(response.value("id").toString());
            AppSettings::instance().setUserType(response.value("userType").toString());
            AppSettings::instance().setIsLoggedIn(true);

            emit signInSucceded(user);
        }
        else{
            QString error = response["message"].toString();
            emit signInFailed(error);      

        }
    }); 
}

void UserRepositoryImpl::signUp(
    const QString& firstName,
    const QString& lastName,
    const QString& email,
    const QString& password,
    const QString& confirmPassword,
    const QString& residentialAddress
)
{
    QJsonObject payload;
    payload["fistName"] = firstName;
    payload["lastName"] = lastName,
    payload["email"] = email;
    payload["password"] = password;
    payload["confirmPassword"] = confirmPassword;
    payload["residentialAddress"] = residentialAddress;

    APIClient::instance().post(
        "/auth/register",
        payload,
        [this](bool success, 
            const QJsonObject& response)
        {
         
        if(success){
            User* user = new User(
                response["id"].toString(),
                response["fistName"].toString(),
                response["lastName"].toString(),
                response["email"].toString(),
                response["phone"].toString(),
                QDateTime::fromString(response["createdAt"].toString(), Qt::ISODate),
                this
            );
            
            //====PERSIST SIGNEDUP USER DATA==
            AppSettings::instance().setUserName(response.value("fistName").toString()+ response.value("lastName").toString());
            AppSettings::instance().setEmail(response.value("email").toString());
            AppSettings::instance().setPhone(response.value("phone").toString());

            emit signUpSucceded(user);
        }
        else{
            QString error = response["message"].toString();   
            emit signUpFailed(error);      

        }
    });
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
        
    });
}

void UserRepositoryImpl::verifyEmail(const QString &email)
{
    QJsonObject payload;
    payload["email"] = email;
    APIClient::instance().post(
        "/auth/verifyEmail",
        payload,
        [this](bool success,
               const QJsonObject& response)
        {

            if(success){
                emit emailVerified(response["status"].toString());
            }

        }
    );
}

void UserRepositoryImpl::checkExistingAccountWithEmail(const QString &email)
{
    QJsonObject payload;
    payload["email"] = email;
    APIClient::instance().post(
        "/auth/checkExistingAccountWithEmail",
        payload,
        [this](bool success,
               const QJsonObject& response)
        {

            if(success){
                emit emailVerified(response["status"].toString());
            }

        }
        );
}

