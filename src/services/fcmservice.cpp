#include "fcmservice.h"
#include "core/utils/appsettings.h"
#include "services/apiclient.h"

#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>

#if defined(Q_OS_ANDROID)
#include <QJniObject>
#include <QJniEnvironment>
#include <QCoreApplication>
#endif

namespace {
constexpr int kPollIntervalMs = 3000;
}

FcmService::FcmService(QObject *parent)
    : QObject(parent)
{
    m_pollTimer = new QTimer(this);
    m_pollTimer->setInterval(kPollIntervalMs);
    m_pollTimer->setSingleShot(false);
    connect(m_pollTimer, &QTimer::timeout, this, &FcmService::pollPendingData);

    // Start polling when user is logged in
    connect(&AppSettings::instance(), &AppSettings::userSessionChanged, this, [this]() {
        if (AppSettings::instance().isLoggedIn() && !m_pollTimer->isActive()) {
            m_pollTimer->start();
            // Also try to get the token right away
            registerToken();
        } else if (!AppSettings::instance().isLoggedIn() && m_pollTimer->isActive()) {
            m_pollTimer->stop();
        }
    });

    // Start polling if already logged in
    if (AppSettings::instance().isLoggedIn()) {
        QTimer::singleShot(3000, this, [this]() {
            m_pollTimer->start();
            registerToken();
        });
    }
}

FcmService::~FcmService()
{
}

QString FcmService::getFcmToken()
{
    return m_currentToken;
}

void FcmService::registerToken()
{
#if defined(Q_OS_ANDROID)
    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid()) {
        qWarning() << "[FCM] No valid Android context";
        return;
    }

    QJniObject firebaseMessaging = QJniObject::callStaticObjectMethod(
        "com/google/firebase/messaging/FirebaseMessaging",
        "getInstance",
        "()Lcom/google/firebase/messaging/FirebaseMessaging;");
    if (!firebaseMessaging.isValid()) {
        qWarning() << "[FCM] FirebaseMessaging.getInstance() failed";
        return;
    }

    QJniObject tokenTask = firebaseMessaging.callObjectMethod(
        "getToken", "()Lcom/google/android/gms/tasks/Task;");
    if (!tokenTask.isValid()) {
        qWarning() << "[FCM] getToken() returned invalid task";
        return;
    }

    // Fetch the token asynchronously. Never call Tasks.await() on the main
    // (Qt) thread - it throws and crashes the app. Instead attach a listener
    // (on the main Android looper) that stores the token in FcmBridge, which
    // pollPendingData() picks up on the next poll.
    QJniObject listener("com/accofinder/TokenListener");
    tokenTask.callMethod<void>(
        "addOnSuccessListener",
        "(Lcom/google/android/gms/tasks/OnSuccessListener;)Lcom/google/android/gms/tasks/Task;",
        listener.object());
#else
    // Non-Android: nothing to register
#endif
}

void FcmService::unregisterToken()
{
    sendTokenToBackend(QString());
    m_currentToken.clear();
}

void FcmService::pollPendingData()
{
#if defined(Q_OS_ANDROID)
    QJniEnvironment env;

    // Check for refreshed token from FcmBridge
    QJniObject tokenResult = QJniObject::callStaticObjectMethod(
        "com/accofinder/FcmBridge",
        "consumePendingToken",
        "()Ljava/lang/String;");
    if (tokenResult.isValid() && !tokenResult.toString().isEmpty()) {
        QString newToken = tokenResult.toString();
        qInfo() << "[FCM] Got refreshed token from FcmBridge";
        m_currentToken = newToken;
        if (AppSettings::instance().isLoggedIn()) {
            sendTokenToBackend(newToken);
        }
        emit fcmTokenReceived(newToken);
    }

    // Check for pending foreground notification from FcmBridge
    QJniObject notifResult = QJniObject::callStaticObjectMethod(
        "com/accofinder/FcmBridge",
        "consumePendingNotification",
        "()[Ljava/lang/String;");
    if (notifResult.isValid()) {
        jobjectArray arr = static_cast<jobjectArray>(notifResult.object());
        if (arr != nullptr && env->GetArrayLength(arr) >= 2) {
            QJniObject title(env->GetObjectArrayElement(arr, 0));
            QJniObject body(env->GetObjectArrayElement(arr, 1));
            if (title.isValid() && body.isValid()) {
                qInfo() << "[FCM] Foreground notification received:" << title.toString();
                emit notificationReceived(title.toString(), body.toString());
            }
        }
    }
#endif
}

void FcmService::sendTokenToBackend(const QString &token)
{
    const AppSettings &settings = AppSettings::instance();
    if (settings.token().isEmpty()) {
        qWarning() << "[FCM] No auth token, cannot register FCM token";
        return;
    }

    QJsonObject payload;
    payload[QStringLiteral("fcmToken")] = token;

    APIClient::instance().patch(
        QStringLiteral("/users/me/fcm-token"),
        payload,
        [](bool success, const QJsonObject &response) {
            if (success) {
                qInfo() << "[FCM] Token registered with backend successfully";
            } else {
                qWarning() << "[FCM] Failed to register token:" << response;
            }
        }
    );
}
