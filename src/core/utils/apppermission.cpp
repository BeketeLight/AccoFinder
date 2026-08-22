#include "apppermission.h"

AppPermission::AppPermission(QObject *parent)
    : QObject{parent}
{}

AppPermission &AppPermission::instance()
{
    static AppPermission appPermission;
    return appPermission;
}


/**
 * @brief AppPermission::requestCameraPeremision
 * request camera peremiasion in android
 */
void AppPermission::requestCameraPeremision()
{
    QCameraPermission camerPermission;
    qApp->requestPermission(camerPermission,this,[this](const QPermission &results) {
        //checking the result
        if(results.status() == Qt::PermissionStatus::Denied) {
            qDebug()<< "Camera Access Denied";
        } else if(results.status() == Qt::PermissionStatus::Undetermined) {
            qDebug()<< "Camera Status Undefined. Make sure that the Camera is Oky and try again";
        }else if(results.status() == Qt::PermissionStatus::Granted) {
            qDebug()<< "Camera Access granted";
        }

    });
}