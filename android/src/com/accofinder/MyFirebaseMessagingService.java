package com.accofinder;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class MyFirebaseMessagingService extends FirebaseMessagingService {
    private static final String TAG = "FCMService";
    private static final String CHANNEL_ID = "fcm_notification_channel";

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        Log.d(TAG, "FCM token refreshed: " + token.substring(0, Math.min(20, token.length())) + "...");
        FcmBridge.onTokenRefreshed(token);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        Log.d(TAG, "FCM message received from: " + remoteMessage.getFrom());

        Map<String, String> data = remoteMessage.getData();
        String title = data.get("title");
        String body = data.get("body");

        // Fallback to notification payload if data payload doesn't carry title/body
        if (title == null || title.isEmpty()) {
            RemoteMessage.Notification n = remoteMessage.getNotification();
            title = (n != null && n.getTitle() != null) ? n.getTitle() : "AccoFinder";
        }
        if (body == null || body.isEmpty()) {
            RemoteMessage.Notification n = remoteMessage.getNotification();
            body = (n != null && n.getBody() != null) ? n.getBody() : "You have a new notification";
        }

        // Always show a system notification (works in both foreground and background)
        showNotification(title, body, data);

        // When in foreground, also forward to Qt so the app can react in-app
        if (NativeBridge.isQtReady(getApplicationContext())) {
            Log.d(TAG, "App in foreground, also forwarding to Qt via FcmBridge");
            FcmBridge.onNotificationReceived(title, body);
        }
    }

    private void showNotification(String title, String body, Map<String, String> data) {
        NotificationManager nm = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "AccoFinder Notifications",
                NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Push notifications from AccoFinder");
            nm.createNotificationChannel(channel);
        }

        Intent intent = getPackageManager().getLaunchIntentForPackage("com.accofinder");
        if (intent == null) {
            Log.e(TAG, "No launch intent found");
            return;
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);

        int pendingFlags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            pendingFlags |= PendingIntent.FLAG_IMMUTABLE;
        }
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, pendingFlags);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true);

        String notificationId = data.get("notificationId");
        int id = (notificationId != null) ? notificationId.hashCode() : (int) (System.currentTimeMillis() % Integer.MAX_VALUE);

        nm.notify(id, builder.build());
        Log.d(TAG, "System notification shown with id: " + id);
    }
}
