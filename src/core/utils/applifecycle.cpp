#include "applifecycle.h"

#include <QCoreApplication>

#if defined(Q_OS_ANDROID)
#include <QJniObject>
#endif

AppLifecycle::AppLifecycle(QObject *parent)
    : QObject(parent)
{
}

void AppLifecycle::quit()
{
#if defined(Q_OS_ANDROID)
    // Qt's quit path alone can leave the Activity alive with a blank window.
    // Ask the Activity to finish on the Android UI thread, then unwind Qt.
    QJniObject::callStaticMethod<void>("com/accofinder/DeepLinkActivity",
                                       "finishFromQt", "()V");
#endif
    QCoreApplication::quit();
}
