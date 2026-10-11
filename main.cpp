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
#include "src/presentation/models/propertylistmodel.h"
#include "src/services/cachedimageprovider.h"
#include "src/services/socketioclient.h"
#include "src/services/fcmservice.h"
#include <QQmlContext>
#include <QTimer>
#include <QUrl>
#include <QFileOpenEvent>
#include <functional>

#if defined(Q_OS_ANDROID)
#include <QJniObject>
// Consumes any Google OAuth deep link (accofinder://auth?...) that launched or
// re-launched the app, forwarding it to AuthController so it can finalise the
// Google sign-in with the tokens carried in the URL.
static QString takePendingDeepLinkUrl()
{
    QJniObject result = QJniObject::callStaticObjectMethod(
        "com/accofinder/DeepLinkActivity",
        "consumePendingUrl",
        "()Ljava/lang/String;");
    if (!result.isValid())
        return QString();
    return result.toString();
}

static bool hasPendingDeepLink()
{
    return QJniObject::callStaticMethod<jboolean>(
        "com/accofinder/DeepLinkActivity",
        "hasPendingUrl",
        "()Z");
}
#endif

// Google sign-in finishes by redirecting the browser back into the app with a
// custom-scheme link. Every platform delivers that link differently, so the
// capture has to cover all of them or the user is stranded on the Google page:
//   * Android  - an ACTION_VIEW intent, surfaced through DeepLinkActivity and
//                polled over JNI (see below).
//   * macOS    - a QFileOpenEvent.
//   * Windows/Linux - a command line argument.
// Recognising the scheme up front keeps unrelated launches (and Qt's own
// "-qwindowgeometry" style flags) out of the OAuth path.
static bool isGoogleRedirectUrl(const QString &candidate)
{
    return candidate.startsWith(QLatin1String("accofinder://"),
                                Qt::CaseInsensitive);
}

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
#if defined(Q_OS_ANDROID)
    auto androidApp = app.nativeInterface<QNativeInterface::QAndroidApplication>();
    const bool hasAndroidSplash = (androidApp != nullptr);
#else
    const bool hasAndroidSplash = false;
#endif

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
    SocketIOClient socketIOClient;
    PropertyListModel propertyListModel;
    FcmService fcmService;
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
    engine.rootContext()->setContextProperty("SocketIO", &socketIOClient);
    engine.rootContext()->setContextProperty("PropertyListModel", &propertyListModel);
    engine.rootContext()->setContextProperty("FcmService", &fcmService);

    // Realtime notifications: start the Socket.IO stream once signed in, stop it
    // on logout, and refresh the notification model immediately when a
    // "notification" event arrives (instead of waiting for the 30s poll).
    auto startSocketForCurrentUser = [&socketIOClient]() {
        const AppSettings& s = AppSettings::instance();
        if (s.isLoggedIn() && !s.userId().isEmpty()) {
            qInfo() << "[Main] Starting socket for user:" << s.userId();
            socketIOClient.stop();
            socketIOClient.start(s.userId(), s.userType(), s.token());
        }
    };
    startSocketForCurrentUser();
    QObject::connect(&authController, &AuthController::signInSucceded, &app,
                     startSocketForCurrentUser);
    QObject::connect(&authController, &AuthController::userLoggedOut,
                     &socketIOClient, [&socketIOClient]() {
        socketIOClient.stop();
    });
    QObject::connect(&socketIOClient, &SocketIOClient::notificationReceived,
                     &notificationViewModel, &NotificationViewModel::refreshCurrent);
    QObject::connect(&appSettings, &AppSettings::userSessionChanged,
                     &app, startSocketForCurrentUser);
    QObject::connect(&socketIOClient, &SocketIOClient::errorOccurred,
                     &app, [](const QString& msg) {
        qWarning() << "[Main] SocketIO error:" << msg;
    });

    // FCM: register token on login, unregister on logout
    QObject::connect(&authController, &AuthController::signInSucceded, &fcmService,
                     [&fcmService]() { fcmService.registerToken(); });
    QObject::connect(&authController, &AuthController::userLoggedOut, &fcmService,
                     [&fcmService]() { fcmService.unregisterToken(); });
    QObject::connect(&appSettings, &AppSettings::userSessionChanged, &fcmService,
                     [&fcmService]() {
        if (AppSettings::instance().isLoggedIn()) {
            fcmService.registerToken();
        }
    });
    // Forward FCM foreground notifications to refresh the notification list
    QObject::connect(&fcmService, &FcmService::notificationReceived,
                     &notificationViewModel, &NotificationViewModel::refreshCurrent);

    // Shared, session-scoped lists must never leak from one user into the
    // next (or into the logged-out state). Reset them whenever the active
    // session changes.
    auto resetSharedModels = [&propertyListModel, &mediaViewModel]() {
        propertyListModel.clear();
        mediaViewModel.clearMedia();
    };
    QObject::connect(&authController, &AuthController::userLoggedOut,
                     &app, resetSharedModels);
    QObject::connect(&authController, &AuthController::signInSucceded,
                     &app, resetSharedModels);

    // A Google sign-in opens the device browser. If the user cancels there,
    // the OAuth redirect deep link never arrives, so AuthController would stay
    // "loading" forever. When the app is brought back to the foreground, give
    // the deep-link poll a short grace window, then cancel the sign-in and
    // clear the spinner instead of hanging.
    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     &app, [&authController](Qt::ApplicationState state) {
        if (state == Qt::ApplicationActive && authController.isGoogleAuthPending()) {
            QTimer::singleShot(6000, [&authController]() {
                if (authController.isGoogleAuthPending() && authController.isLoading())
                    authController.cancelGoogleAuth();
            });
        }
    });
    paymentController.fetchOperators();
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Routes an OAuth redirect into AuthController, rejecting anything that is
    // not one of ours so a stray link can never be mistaken for a session.
    auto forwardGoogleRedirect = [&authController](const QString &url) {
        if (url.isEmpty() || !isGoogleRedirectUrl(url))
            return;
        // The redirect carries a bearer token in its query string, so log the
        // shape only - never the full URL, which would leak it to logcat.
        const QUrl parsed(url);
        qInfo() << "[Main] Google OAuth redirect received:"
                << parsed.scheme() << "://" << parsed.host();
        authController.handleGoogleAuthUrl(url);
    };

#if defined(Q_OS_ANDROID)
    // Poll for Google OAuth deep links (accofinder://auth?...). This covers
    // both a cold start and the case where the app is already running when the
    // OAuth flow redirects back to the app's custom scheme. Each captured URL
    // is forwarded to AuthController so the Google sign-in is finalised.
    auto processAndroidDeepLink = [&forwardGoogleRedirect]() {
        if (!hasPendingDeepLink())
            return;
        forwardGoogleRedirect(takePendingDeepLinkUrl());
    };
    QTimer* deepLinkTimer = new QTimer(&app);
    QObject::connect(deepLinkTimer, &QTimer::timeout, &app, processAndroidDeepLink);
    deepLinkTimer->start(500);

    // Handle a deep link that was already present at launch.
    QTimer::singleShot(200, &app, processAndroidDeepLink);
#endif

    // Desktop launches hand the redirect over as a plain command line argument.
    for (const QString &arg : app.arguments()) {
        if (isGoogleRedirectUrl(arg))
            QTimer::singleShot(0, &app, [forwardGoogleRedirect, arg]() {
                forwardGoogleRedirect(arg);
            });
    }

    // macOS delivers the same link as a QFileOpenEvent instead, both when the
    // app is already running and when the link is what launched it.
    class DeepLinkEventFilter : public QObject
    {
    public:
        explicit DeepLinkEventFilter(std::function<void(const QString &)> sink,
                                     QObject *parent = nullptr)
            : QObject(parent), m_sink(std::move(sink)) {}

    protected:
        bool eventFilter(QObject *watched, QEvent *event) override
        {
            if (event->type() == QEvent::FileOpen) {
                auto *open = static_cast<QFileOpenEvent *>(event);
                const QString url = open->url().toString();
                if (!url.isEmpty() && m_sink)
                    m_sink(url);
            }
            return QObject::eventFilter(watched, event);
        }

    private:
        std::function<void(const QString &)> m_sink;
    };
    auto *deepLinkFilter = new DeepLinkEventFilter(forwardGoogleRedirect, &app);
    app.installEventFilter(deepLinkFilter);

    engine.loadFromModule("AccoFinder", "Main");

    // Hide the sticky Android splash as soon as the UI is ready, instead of
    // waiting a fixed 3 seconds. The splash is dismissible once the first
    // frame has been rendered, so we give the event loop a single cycle to
    // paint, then remove it. A short fallback guarantees it never lingers.
#if defined(Q_OS_ANDROID)
    if (hasAndroidSplash) {
        QTimer::singleShot(0, [androidApp]() {
            androidApp->hideSplashScreen(300);
        });
        QTimer::singleShot(2000, [androidApp]() {
            androidApp->hideSplashScreen(300);
        });
    }
#else
    Q_UNUSED(hasAndroidSplash)
#endif

    return QCoreApplication::exec();
}
