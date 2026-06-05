#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include "src/core/utils/appsettings.h"
#include <QQmlContext>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

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
