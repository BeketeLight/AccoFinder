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
    private static String sPendingToken = null;
    private static String sPendingTitle = null;
    private static String sPendingBody = null;
    private static volatile Context sAppContext = null;
    private static volatile boolean sFirebaseReady = false;

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