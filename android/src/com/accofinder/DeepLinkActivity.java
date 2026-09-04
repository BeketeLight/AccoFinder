package com.accofinder;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import org.qtproject.qt.android.bindings.QtActivity;

/**
 * Handles the accofinder:// Google OAuth deep link.
 * Subclasses QtActivity so the app can launch directly from a deep link and
 * still initialise the full Qt runtime. The incoming URL is stored and later
 * consumed from C++ (via JNI) so AuthController can finalise the sign-in.
 */
public class DeepLinkActivity extends QtActivity {
    private static final String TAG = "DeepLinkActivity";

    private static volatile String pendingUrl = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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
        Log.d(TAG, "Captured deep link: " + pendingUrl);
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
