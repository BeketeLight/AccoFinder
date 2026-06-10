#include "userrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonValue>
#include "services/apiclient.h"

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
        "api/auth/login",
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
        "api/auth/register",
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
        "api/auth/logout",
        QJsonObject(),
        [this](bool success, 
            const QJsonObject& response)
        {
         
        if(success){
            APIClient::instance().setAuthToken("");
            emit logOutSuccess();
        }
        else{
        
        }
    });
}
