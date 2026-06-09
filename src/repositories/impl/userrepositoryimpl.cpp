#include "userrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonValue>

UserRepositoryImpl::UserRepositoryImpl
:IUserRepository(parent) {}

User *UserRepositoryImpl::signIn(
    const QString& email,
    const QString& password)
{
    //sending QJsonObject to the server
    QJsonObject payload;
    payload["email"] = email;   
    payload["password"] = password;

    APiClient::instance().post(
        "api/auth/login",
        payload,
        [this](bool success, 
            const QJsonObject& response)
        {
         
        if(success){
            user* user = new User();
            user->setName(response["name"].toString());

            emit signInSucceded(user);
        }
        else{
            
            emit signInFailed(error);      

        }
    }); 
}

User *UserRepositoryImpl::signUp(
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

    APiClient::instance().post(
        "api/auth/register",
        payload,
        [this](bool success, 
            const QJsonObject& response)
        {
         
        if(success){
            user* user = new User();
            user->setName(response["name"].toString());
            user->setEmail(response["email"].toString());

            emit signUpSuccess(user);
        }
        else{
            QString error = response["message"].toString();   
            emit signUpFailed(error);      

        }
    });
}

User *UserRepositoryImpl::logOut()
{
    APiClient::instance().post(
        "api/auth/logout",
        QJsonObject(),
        [this](bool success, 
            const QJsonObject& response)
        {
         
        if(success){
            APIClient::instance().clearToken("");
            emit logOutSuccess();
        }
        else{
        
        }
    });
}
