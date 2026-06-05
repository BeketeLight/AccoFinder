#include "appsettings.h"

AppSettings::AppSettings(QObject *parent)
    : QObject{parent}
{}

AppSettings &AppSettings::instance()
{
    static AppSettings appSettings;
    return appSettings;
}

void AppSettings::setStatusBarAppearance(const QColor &backgroundColor, bool darkIcons)
{
#if defined(Q_OS_ANDROID)
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([=]() -> QVariant {
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (!activity.isValid()) {
            qWarning() << "setStatusBarAppearance: No valid Android activity";
            return QVariant(false);
        }

        QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
        if (!window.isValid()) {
            qWarning() << "setStatusBarAppearance: No valid window";
            return QVariant(false);
        }

        jint sdkVersion = QJniObject::getStaticField<jint>("android/os/Build$VERSION", "SDK_INT");

        // 1. Enable drawing behind system bars + make status bar TRANSPARENT (best for edge-to-edge)
        window.callMethod<void>("addFlags", "(I)V", 0x80000000);           // FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS
        window.callMethod<void>("clearFlags", "(I)V", 0x04000000);         // clear FLAG_TRANSLUCENT_STATUS

        // Use the color you pass (ARGB format for JNI)
        jint statusColor = backgroundColor.alpha() << 24 |
                           backgroundColor.red()   << 16 |
                           backgroundColor.green() << 8  |
                           backgroundColor.blue();

        window.callMethod<void>("setStatusBarColor", "(I)V", statusColor);

        // 2. Force icon/text appearance (dark icons = light status bar appearance)
        if (sdkVersion >= 30) {
            // Preferred modern way (API 30+ / Android 11+)
            QJniObject insetsController = window.callObjectMethod("getInsetsController", "()Landroid/view/WindowInsetsController;");
            if (insetsController.isValid()) {
                jint appearance = darkIcons ? 0x00000008 : 0x00000000;  // APPEARANCE_LIGHT_STATUS_BARS = 0x08
                insetsController.callMethod<void>("setSystemBarsAppearance", "(II)V", appearance, 0x00000008);
            }
        }

        if (sdkVersion >= 23 && sdkVersion < 30) {
            // Legacy fallback (API 23–29)
            QJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
            if (decorView.isValid()) {
                jint uiFlags = decorView.callMethod<jint>("getSystemUiVisibility", "()I");
                if (darkIcons) {
                    uiFlags |= 0x00002000;  // SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
                } else {
                    uiFlags &= ~0x00002000;
                }
                decorView.callMethod<void>("setSystemUiVisibility", "(I)V", uiFlags);
            }
        }

        return QVariant(true);
    }).waitForFinished();
#else
    Q_UNUSED(backgroundColor);
    Q_UNUSED(darkIcons);
#endif
}
