package com.accofinder;

import android.content.Context;
import android.os.Build;
import android.util.Log;

public class NativeBridge {
    private static final String TAG = "NativeBridge";
    private static boolean isInitialized = false;

    static {
        try {
            // Try ABI-specific library name first, then fall back to generic name.
            // Qt 6 androiddeployqt may name the library with or without the ABI suffix.
            String baseName = "appAccoFinder";
            String abiSpecific = baseName + "_" + Build.SUPPORTED_ABIS[0];
            try {
                System.loadLibrary(abiSpecific);
                isInitialized = true;
                Log.d(TAG, "Library loaded: " + abiSpecific);
            } catch (UnsatisfiedLinkError e1) {
                try {
                    System.loadLibrary(baseName);
                    isInitialized = true;
                    Log.d(TAG, "Library loaded: " + baseName);
                } catch (UnsatisfiedLinkError e2) {
                    Log.e(TAG, "Failed to load native library with any name", e2);
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error loading native library", e);
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
            return;
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
