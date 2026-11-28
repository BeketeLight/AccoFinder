package com.accofinder;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import org.qtproject.qt.android.bindings.QtActivity;

import java.lang.ref.WeakReference;

/**
 * Handles the accofinder:// Google OAuth deep link.
 * Subclasses QtActivity so the app can launch directly from a deep link and
 * still initialise the full Qt runtime. The incoming URL is stored and later
 * consumed from C++ (via JNI) so AuthController can finalise the sign-in.
 */
public class DeepLinkActivity extends QtActivity {
    private static final String TAG = "DeepLinkActivity";

    private static volatile String pendingUrl = null;
    private static volatile WeakReference<DeepLinkActivity> activeActivity =
            new WeakReference<DeepLinkActivity>(null);

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activeActivity = new WeakReference<DeepLinkActivity>(this);
        // Capture the app context for lazy Firebase initialization. Since we
        // removed FirebaseInitProvider, the first real Firebase use (token
        // request / foreground notification) must bootstrap FirebaseApp itself.
        FcmBridge.initialize(this);
        captureUrl(getIntent());
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        captureUrl(intent);
    }

    private void captureUrl(Intent intent) {
        if (intent == null) return;
        final Uri data = intent.getData();
        if (data == null) return;
        pendingUrl = data.toString();
        // The redirect carries a bearer token in its query string, so log the
        // shape only. Logging the full URL would leak the session to logcat.
        Log.d(TAG, "Captured deep link: " + data.getScheme() + "://" + data.getHost());
    }

    @Override
    protected void onDestroy() {
        if (activeActivity.get() == this)
            activeActivity.clear();
        super.onDestroy();
    }

    /**
     * Called from native C++ when the app should exit. Qt's quit path alone
     * can leave this Activity alive with a blank window, so finish explicitly.
     */
    public static void finishFromQt() {
        final DeepLinkActivity activity = activeActivity.get();
        if (activity == null)
            return;

        Log.d(TAG, "Finishing activity from Qt");
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "Activity finish requested from Qt");
                if (!activity.isFinishing())
                    activity.finish();

                // Qt tears its native runtime down on quit. If the process is
                // left cached, the next launch reuses it with a dead runtime and
                // shows a blank window. Terminate here so the next start is a
                // cold start. finish() has already told the system to close the
                // Activity, so the task transition survives process death.
                Log.d(TAG, "Terminating process after Qt quit");
                android.os.Process.killProcess(android.os.Process.myPid());
                System.exit(0);
            }
        });
    }

    /**
     * Returns and clears the pending deep link URL. Called from native C++.
     */
    public static String consumePendingUrl() {
        final String url = pendingUrl;
        pendingUrl = null;
        return url;
    }

    /**
     * Returns true if a deep link URL is still pending (not yet consumed).
     */
    public static boolean hasPendingUrl() {
        return pendingUrl != null && !pendingUrl.isEmpty();
    }
}
