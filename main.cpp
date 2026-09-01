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
#include "src/presentation/viewmodels/userviewmodel.h"
#include "src/presentation/viewmodels/agentviewmodel.h"
#include "src/presentation/viewmodels/agentapplicationviewmodel.h"
#include "src/presentation/viewmodels/paymentsoverviewviewmodel.h"
#include "src/presentation/viewmodels/adminnotificationsviewmodel.h"
#include "src/services/cachedimageprovider.h"
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
    // Register an async image provider that caches decoded images in memory
    // (and raw bytes on disk). Both thumbnails and the lightbox load through
    // "image://cached/" so they share already-decoded pixels instead of making
    // repeated network requests.
    CachedImageProvider *cachedImageProvider = new CachedImageProvider(&engine);
    engine.addImageProvider("cached", cachedImageProvider);
    // Expose the provider to QML so delete flows can invalidate a removed
    // image's cache entry via ImageCache.invalidateUrl(url).
    engine.rootContext()->setContextProperty("ImageCache", cachedImageProvider);
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
    UserViewModel userViewModel;
    AgentViewModel agentViewModel;
    AgentApplicationViewModel agentApplicationViewModel;
    PaymentsOverviewViewModel paymentsOverviewViewModel;
    AdminNotificationsViewModel adminNotificationsViewModel;
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
    engine.rootContext()->setContextProperty("UserViewModel", &userViewModel);
    engine.rootContext()->setContextProperty("AgentViewModel", &agentViewModel);
    engine.rootContext()->setContextProperty("AgentApplicationViewModel", &agentApplicationViewModel);
    engine.rootContext()->setContextProperty("PaymentsOverviewViewModel", &paymentsOverviewViewModel);
    engine.rootContext()->setContextProperty("AdminNotificationsViewModel", &adminNotificationsViewModel);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("AccoFinder", "Main");

    return QCoreApplication::exec();
}
