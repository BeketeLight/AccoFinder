package com.accofinder;

import android.content.Context;
import android.util.Log;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;

/**
 * JNI bridge for FCM token and notification forwarding to Qt/C++ layer.
 * Called from MyFirebaseMessagingService when tokens refresh or messages arrive.
 *
 * FirebaseApp initialization is deliberately lazy (see the remove of
 * FirebaseInitProvider in AndroidManifest.xml): initializing Firebase on first
 * use instead of during process start keeps the pre-splash cold-start path
 * empty. Any code path that needs Firebase (FCM service, token request) calls
 * initialize() first, which is idempotent.
 */
public class FcmBridge {
    private static final String TAG = "FcmBridge";
    private static final String PREFS = "accofinder_notifications";
    private static final String KEY_ENABLED = "enabled";
    private static final String KEY_BOOKINGS = "bookings";
    private static final String KEY_PROMOTIONS = "promotions";
    private static final String KEY_SYSTEM = "system";
    private static String sPendingToken = null;
    private static String sPendingTitle = null;
    private static String sPendingBody = null;
    private static volatile Context sAppContext = null;
    private static volatile boolean sFirebaseReady = false;

    /**
     * Mirrors the user's notification preferences into SharedPreferences so the
     * FCM service (which may run without Qt) can honour them before showing a
     * system notification. Called from C++ whenever a toggle changes.
     */
    public static synchronized void setNotificationPreferences(
            boolean enabled, boolean bookings, boolean promotions, boolean system) {
        Context context = sAppContext;
        if (context == null) return;
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_ENABLED, enabled)
                .putBoolean(KEY_BOOKINGS, bookings)
                .putBoolean(KEY_PROMOTIONS, promotions)
                .putBoolean(KEY_SYSTEM, system)
                .apply();
    }

    private static boolean readPref(Context context, String key, boolean fallback) {
        if (context == null) return fallback;
        return context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getBoolean(key, fallback);
    }

    /** True when the master notification switch is on. */
    public static boolean areNotificationsEnabled(Context context) {
        return readPref(context, KEY_ENABLED, true);
    }

    /**
     * True when the category carried by the message is enabled. Unknown or
     * missing categories are treated as "system" so they follow the system
     * toggle rather than being silently dropped.
     */
    public static boolean isCategoryEnabled(Context context, String category) {
        if (!areNotificationsEnabled(context)) return false;
        String c = (category == null) ? "" : category.trim().toLowerCase();
        if (c.contains("booking") || c.contains("payment") || c.contains("reservation"))
            return readPref(context, KEY_BOOKINGS, true);
        if (c.contains("promo") || c.contains("marketing") || c.contains("deal"))
            return readPref(context, KEY_PROMOTIONS, true);
        return readPref(context, KEY_SYSTEM, true);
    }

    /**
     * Captures the application context and initializes FirebaseApp once.
     * Safe to call from any thread and any number of times.
     */
    public static synchronized void initialize(Context context) {
        if (context == null) return;
        if (sAppContext == null) {
            sAppContext = context.getApplicationContext();
        }
        if (sFirebaseReady) return;
        try {
            if (FirebaseApp.getApps(sAppContext).isEmpty()) {
                FirebaseApp.initializeApp(sAppContext);
            }
            sFirebaseReady = true;
        } catch (Exception e) {
            Log.e(TAG, "FirebaseApp.initializeApp failed", e);
        }
    }

    /**
     * Fetches the FCM token entirely in Java. The token is delivered to the
     * Qt/C++ layer through the same asynchronously-stored pending token that
     * consumePendingToken() polls.
     *
     * This intentionally keeps ALL Firebase / com.google.android.gms.tasks
     * interaction inside Java. Calling those classes from C++ via JNI is what
     * aborts the app on some devices (JNI return-type mismatches, listener
     * overhead), so the native layer only triggers this and polls the result.
     */
    public static synchronized void requestToken() {
        initialize(sAppContext);
        if (!sFirebaseReady) {
            Log.e(TAG, "requestToken() skipped: Firebase not initialized yet");
            return;
        }
        try {
            FirebaseMessaging.getInstance().getToken()
                    .addOnSuccessListener(token -> {
                        if (token != null) {
                            onTokenRefreshed(token);
                        }
                    })
                    .addOnFailureListener(e ->
                            Log.e(TAG, "getToken() failed", e));
        } catch (Exception e) {
            Log.e(TAG, "requestToken() failed, will retry on next poll", e);
        }
    }

    public static synchronized void onTokenRefreshed(String token) {
        Log.d(TAG, "Token refreshed, storing for Qt pickup");
        sPendingToken = token;
    }

    public static synchronized void onNotificationReceived(String title, String body) {
        Log.d(TAG, "Foreground notification received, storing for Qt pickup");
        sPendingTitle = title;
        sPendingBody = body;
    }

    /** Called from C++ to poll for a refreshed token. Returns null if none pending. */
    public static synchronized String consumePendingToken() {
        String token = sPendingToken;
        sPendingToken = null;
        return token;
    }

    /** Called from C++ to poll for a pending foreground notification. Returns null if none. */
    public static synchronized String[] consumePendingNotification() {
        if (sPendingTitle == null) return null;
        String[] result = { sPendingTitle, sPendingBody };
        sPendingTitle = null;
        sPendingBody = null;
        return result;
    }
}