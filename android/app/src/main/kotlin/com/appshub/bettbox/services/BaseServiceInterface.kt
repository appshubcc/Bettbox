package com.appshub.bettbox.services

import android.annotation.SuppressLint
import android.app.Notification
import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.R
import com.appshub.bettbox.models.VpnOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.withContext
import android.content.ComponentName
import android.content.Intent

interface BaseServiceInterface {
    suspend fun start(options: VpnOptions): Int
    fun stop()
    suspend fun startForeground()
}

suspend fun Service.createBettboxNotificationBuilder(): NotificationCompat.Builder =
    withContext(Dispatchers.IO) {
        val defaultComponent = ComponentName(packageName, "com.appshub.bettbox.MainActivity")
        val lightComponent = ComponentName(packageName, "com.appshub.bettbox.MainActivityLight")

        val targetComponent = NotificationComponentCache.get(packageManager, defaultComponent, lightComponent)

        android.util.Log.d("Notification", "Using ${targetComponent.className}")

        val intent = Intent().apply {
            component = targetComponent
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val flags = if (Build.VERSION.SDK_INT >= 31) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = withContext(Dispatchers.Main) {
            PendingIntent.getActivity(this@createBettboxNotificationBuilder, 0, intent, flags)
        }

        NotificationCompat.Builder(this@createBettboxNotificationBuilder, GlobalState.NOTIFICATION_CHANNEL).apply {
            setSmallIcon(R.drawable.ic)
            setContentTitle("Bettbox")
            setContentIntent(pendingIntent)
            setCategory(NotificationCompat.CATEGORY_SERVICE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                foregroundServiceBehavior = FOREGROUND_SERVICE_IMMEDIATE
            }
            setOngoing(true)
            setShowWhen(false)
            setOnlyAlertOnce(true)
        }
    }

fun Service.ensureNotificationChannel() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
    val manager = getSystemService(NotificationManager::class.java)
    val channel = manager?.getNotificationChannel(GlobalState.NOTIFICATION_CHANNEL)
    if (channel == null || channel.importance != NotificationManager.IMPORTANCE_LOW) {
        manager?.createNotificationChannel(
            NotificationChannel(GlobalState.NOTIFICATION_CHANNEL, "Bettbox Service", NotificationManager.IMPORTANCE_LOW)
        )
    }
}

@SuppressLint("ForegroundServiceType")
fun Service.startForeground(notification: Notification, useSpecialType: Boolean = true) {
    ensureNotificationChannel()

    val type = if (Build.VERSION.SDK_INT >= 34 && useSpecialType && !GlobalState.isSmartStopped) {
        android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
    } else {
        0
    }

    runCatching {
        if (type != 0) {
            startForeground(GlobalState.NOTIFICATION_ID, notification, type)
        } else {
            startForeground(GlobalState.NOTIFICATION_ID, notification)
        }
    }.onFailure {
        android.util.Log.e("BaseServiceInterface", "startForeground failed: ${it.message}")
        startForeground(GlobalState.NOTIFICATION_ID, notification)
    }
}
