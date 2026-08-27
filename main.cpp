#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QQuickStyle>
#include "src/core/utils/appsettings.h"
#include "src/core/utils/apppermission.h"
#include "src/application/controllers/authcontroller.h"
#include "src/application/controllers/propertycontroller.h"
#include "src/application/controllers/bookingcontroller.h"
#include "src/application/controllers/paymentcontroller.h"
#include "src/application/controllers/disputecontroller.h"
#include "src/application/controllers/roomcontroller.h"
#include "src/application/controllers/usercontroller.h"
#include "src/application/controllers/agentcontroller.h"
#include "src/application/controllers/dashboardcontroller.h"
#include "src/presentation/viewmodels/propertyviewmodel.h"
#include "src/presentation/viewmodels/roomviewmodel.h"
#include "src/presentation/viewmodels/mediaviewmodel.h"
#include "src/presentation/viewmodels/draftviewmodel.h"
#include "src/presentation/viewmodels/bookingviewmodel.h"
#include "src/presentation/viewmodels/disputeslistviewmodel.h"
#include "src/presentation/viewmodels/notificationviewmodel.h"
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
    //Controllers
    AuthController authController;
    PropertyController propertyController;
    BookingController bookingController;
    PaymentController paymentController;
    DisputeController disputeController;
    RoomController roomController;
    UserController userController;
    AgentController agentController;
    DashboardController dashboardController;
    PropertyViewModel propertyViewModel;
    RoomViewModel roomViewModel;
    MediaViewModel mediaViewModel;
    DraftViewModel draftViewModel(&propertyViewModel);
    BookingViewModel bookingViewModel;
    DisputesListViewModel disputesListViewModel;
    NotificationViewModel notificationViewModel;
    //ContextProperty
    engine.rootContext()->setContextProperty("AppSettings", &appSettings);
    engine.rootContext()->setContextProperty("AppPermission", &appPermission);
    engine.rootContext()->setContextProperty("AuthController", &authController);
    engine.rootContext()->setContextProperty("PropertyController", &propertyController);
    engine.rootContext()->setContextProperty("BookingController", &bookingController);
    engine.rootContext()->setContextProperty("PaymentController", &paymentController);
    engine.rootContext()->setContextProperty("DisputeController", &disputeController);
    engine.rootContext()->setContextProperty("RoomController", &roomController);
    engine.rootContext()->setContextProperty("UserController", &userController);
    engine.rootContext()->setContextProperty("AgentController", &agentController);
    engine.rootContext()->setContextProperty("DashboardController", &dashboardController);
    engine.rootContext()->setContextProperty("PropertyViewModel", &propertyViewModel);
    engine.rootContext()->setContextProperty("RoomViewModel", &roomViewModel);
    engine.rootContext()->setContextProperty("MediaViewModel", &mediaViewModel);
    engine.rootContext()->setContextProperty("DraftViewModel", &draftViewModel);
    engine.rootContext()->setContextProperty("BookingViewModel", &bookingViewModel);
    engine.rootContext()->setContextProperty("DisputesListViewModel", &disputesListViewModel);
    engine.rootContext()->setContextProperty("NotificationViewModel", &notificationViewModel);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("AccoFinder", "Main");

    return QCoreApplication::exec();
}
