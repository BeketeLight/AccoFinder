#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include "src/core/utils/appsettings.h"
#include <QQmlContext>
#include <QTimer>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    //SplashScreen
    auto androidApp = app.nativeInterface<QNativeInterface::QAndroidApplication>();
    if (androidApp) {
        QTimer::singleShot(3000, [androidApp]() {
            androidApp->hideSplashScreen(300);
        });
    }

    QQmlApplicationEngine engine;
    //Appsettings
    AppSettings& appSettings = AppSettings::instance();
    //ContextProperty
    engine.rootContext()->setContextProperty("AppSettings", &appSettings);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("AccoFinder", "Main");

    return QCoreApplication::exec();
}
