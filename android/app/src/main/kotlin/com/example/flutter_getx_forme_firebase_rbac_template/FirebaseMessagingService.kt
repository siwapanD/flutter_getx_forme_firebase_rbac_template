package com.example.flutter_getx_forme_firebase_rbac_template

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.media.RingtoneManager

/**
 * Firebase Cloud Messaging Service
 * 
 * Handles incoming FCM messages and notification display
 */
class FirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "FCMService"
        private const val CHANNEL_ID = "default_channel"
        private const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    /**
     * Called when a new FCM token is generated
     */
    override fun onNewToken(token: String) {
        Log.d(TAG, "Refreshed token: $token")
        
        // Send token to your server or store locally
        sendTokenToServer(token)
    }

    /**
     * Called when a message is received
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d(TAG, "From: ${remoteMessage.from}")

        // Check if message contains a data payload
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "Message data payload: ${remoteMessage.data}")
            
            // Handle data payload
            handleDataMessage(remoteMessage.data)
        }

        // Check if message contains a notification payload
        remoteMessage.notification?.let {
            Log.d(TAG, "Message Notification Body: ${it.body}")
            
            // Show notification
            showNotification(
                title = it.title ?: "Notification",
                body = it.body ?: "",
                data = remoteMessage.data
            )
        }
    }

    /**
     * Handle data messages
     */
    private fun handleDataMessage(data: Map<String, String>) {
        // Extract custom data fields
        val action = data["action"]
        val userId = data["user_id"]
        val messageType = data["message_type"]
        
        when (action) {
            "navigate" -> {
                // Handle navigation action
                val route = data["route"]
                Log.d(TAG, "Navigate to: $route")
                // Send to Flutter app via method channel
            }
            "refresh_data" -> {
                // Handle data refresh action
                Log.d(TAG, "Refresh data requested")
                // Send to Flutter app via method channel
            }
            "user_action" -> {
                // Handle user-specific action
                Log.d(TAG, "User action for: $userId")
                // Send to Flutter app via method channel
            }
            else -> {
                Log.d(TAG, "Unknown action: $action")
            }
        }
    }

    /**
     * Show notification to user
     */
    private fun showNotification(title: String, body: String, data: Map<String, String>) {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            // Add extra data from FCM message
            data.forEach { (key, value) ->
                putExtra(key, value)
            }
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )

        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        val notificationManager = NotificationManagerCompat.from(this)
        
        // Check for notification permission (Android 13+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == 
                android.content.pm.PackageManager.PERMISSION_GRANTED) {
                notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
            }
        } else {
            notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
        }
    }

    /**
     * Create notification channel for Android 8.0+
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = getString(R.string.default_notification_channel_name)
            val descriptionText = getString(R.string.default_notification_channel_description)
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            
            val notificationManager: NotificationManager =
                getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * Send token to server
     */
    private fun sendTokenToServer(token: String) {
        // TODO: Implement server communication to store FCM token
        // This should be sent to your backend server for user-specific messaging
        Log.d(TAG, "Sending token to server: $token")
        
        // Example: Store in shared preferences for Flutter app to access
        val sharedPref = getSharedPreferences("fcm_prefs", MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("fcm_token", token)
            apply()
        }
    }
}