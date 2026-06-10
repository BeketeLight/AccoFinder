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
                response["name"].toString(),
                response["email"].toString(),
                response["phone"].toString(),
                QDateTime::fromString(response["createdAt"].toString(), Qt::ISODate),
                this
            );

            //====PERSIST LOGGED IN USER DATA==
            AppSettings& settings = AppSettings::instance();
            settings.setToken(response.value("token").toString());
            settings.setRefreshToken(response.value("refreshToken").toString());
            settings.setUserId(response.value("id").toString());
            settings.setUserType(response.value("userType").toString());
            settings.setIsLoggedIn(true);

            emit signInSucceded(user);
        }
        else{
            QString error = response["message"].toString();
            emit signInFailed(error);      

        }
    }); 
}

void UserRepositoryImpl::signUp(
    const QString& name,
    const QString& email,
    const QString& password,
    const QString& confirmPassword,
    const QString& residentialAddress
)
{
    QJsonObject payload;
    payload["name"] = name;
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
                response["name"].toString(),
                response["email"].toString(),
                response["phone"].toString(),
                QDateTime::fromString(response["createdAt"].toString(), Qt::ISODate),
                this
            );
            
            //====PERSIST SIGNEDUP USER DATA==
            AppSettings& settings = AppSettings::instance();
            settings.setUserName(response.value("name").toString());
            settings.setEmail(response.value("email").toString());
            settings.setPhone(response.value("phone")   .toString());

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
            AppSettings& settings = AppSettings::instance();
            settings.setToken("");
            settings.setRefreshToken("");
            settings.setUserId("");
            settings.setUserType("");
            settings.setIsLoggedIn(false);
        
            emit logOutSucceded();
        }
        
    });
}
