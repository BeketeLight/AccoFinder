package com.accofinder;

import android.util.Log;

/**
 * JNI bridge for FCM token and notification forwarding to Qt/C++ layer.
 * Called from MyFirebaseMessagingService when tokens refresh or messages arrive.
 */
public class FcmBridge {
    private static final String TAG = "FcmBridge";
    private static String sPendingToken = null;
    private static String sPendingTitle = null;
    private static String sPendingBody = null;

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
