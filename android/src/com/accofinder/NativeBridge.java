package com.accofinder;

import android.content.Context;
import android.util.Log;

public class NativeBridge {
    private static final String TAG = "NativeBridge";
    private static boolean isInitialized = false;

    static {
        try {
            System.loadLibrary("appAccoFinder_arm64-v8a");
            isInitialized = true;
            Log.d(TAG, "Library loaded successfully");
        } catch (UnsatisfiedLinkError e) {
            Log.e(TAG, "Library load error", e);
        }
    }

    public static boolean isQtReady(Context context) {
        try {
            android.app.ActivityManager am = (android.app.ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            if (am == null) return false;
            java.util.List<android.app.ActivityManager.RunningAppProcessInfo> processes = am.getRunningAppProcesses();
            if (processes != null) {
                for (android.app.ActivityManager.RunningAppProcessInfo process : processes) {
                    if (process.processName.equals(context.getPackageName()) &&
                        process.importance == android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                        return true;
                    }
                }
            }
            return false;
        } catch (Exception e) {
            Log.e(TAG, "Error checking Qt readiness", e);
            return false;
        }
    }

    public static void invoked() {
        if (!isInitialized) {
            Log.e(TAG, "Native library not loaded");
            throw new IllegalStateException("Native library not loaded");
        }
        try {
            nativeInvoked();
            Log.d(TAG, "nativeInvoked called successfully");
        } catch (Exception e) {
            Log.e(TAG, "Failed to call nativeInvoked", e);
        }
    }

    private static native void nativeInvoked();
}
