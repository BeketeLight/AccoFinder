package com.accofinder;

import android.util.Log;

import com.google.android.gms.tasks.OnSuccessListener;

/**
 * Asynchronous listener for FirebaseMessaging.getToken().
 * The resulting token is stored in FcmBridge so the Qt/C++ layer can pick it
 * up on its next poll. This avoids calling Tasks.await() on the main thread,
 * which would throw and crash the app.
 */
public class TokenListener implements OnSuccessListener<String> {
    private static final String TAG = "TokenListener";

    @Override
    public void onSuccess(String token) {
        Log.d(TAG, "Token resolved asynchronously: "
                + (token == null ? "null" : token.substring(0, Math.min(20, token.length())) + "..."));
        if (token != null) {
            FcmBridge.onTokenRefreshed(token);
        }
    }
}
