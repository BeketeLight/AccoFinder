#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QQuickStyle>
#include "src/core/utils/appsettings.h"
#include "src/core/utils/apppermission.h"
#include "src/application/controllers/authcontroller.h"
#include <QQmlContext>
#include <QTimer>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set the Material style (must be before loading QML)
    QQuickStyle::setStyle("Material");

    qputenv("QT_ANDROID_NO_EXIT_CALL", "true");

    //Settings
    QCoreApplication::setOrganizationName("accofinder");
    QCoreApplication::setOrganizationDomain("accofinder.com");
    QCoreApplication::setApplicationName("accofinder");

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
    //AppPermission
    AppPermission& appPermission = AppPermission::instance();
    //Auth Controller
    AuthController authController;
    //ContextProperty
    engine.rootContext()->setContextProperty("AppSettings", &appSettings);
    engine.rootContext()->setContextProperty("AppPermission", &appPermission);
    engine.rootContext()->setContextProperty("AuthController", &authController);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("AccoFinder", "Main");

    return QCoreApplication::exec();
}
