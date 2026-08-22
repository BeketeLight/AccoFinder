#ifndef APPPERMISSION_H
#define APPPERMISSION_H

#include <QObject>
#include <QCoreApplication>
#if defined(Q_OS_ANDROID)
#include <QtCore>
#include <jni.h>
#include <android/log.h>
#define LOG_TAG "NativeWorker"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#endif
#include <QPermission>

class AppPermission : public QObject
{
    Q_OBJECT
public:
    explicit AppPermission(QObject *parent = nullptr);
    static AppPermission& instance();
public slots:
      void requestCameraPeremision();

signals:
};

#endif // APPPERMISSION_H
