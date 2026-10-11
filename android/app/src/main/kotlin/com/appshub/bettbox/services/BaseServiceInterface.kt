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

import android.graphics.BitmapFactory

interface BaseServiceInterface {
    suspend fun start(options: VpnOptions): Int
    fun stop()
    suspend fun startForeground()
}

suspend fun Service.createBettboxNotificationBuilder(
    isSuspended: Boolean = GlobalState.isSmartStopped,
    isHighPriority: Boolean = GlobalState.isNotificationHighPriority
): NotificationCompat.Builder =
    withContext(Dispatchers.IO) {
        val defaultComponent = ComponentName(packageName, "com.appshub.bettbox.MainActivity")
        val lightComponent = ComponentName(packageName, "com.appshub.bettbox.MainActivityLight")
        val darkComponent = ComponentName(packageName, "com.appshub.bettbox.MainActivityDark")

        val targetComponent = NotificationComponentCache.get(packageManager, defaultComponent, lightComponent, darkComponent)

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

        val isDark = targetComponent == darkComponent
        val largeIconRes = if (isDark) {
            R.mipmap.ic_launcher
        } else {
            R.mipmap.ic_launcher_light
        }

        val largeIconBitmap = runCatching {
            BitmapFactory.decodeResource(resources, largeIconRes)
        }.getOrNull()

        val channelId = when {
            isSuspended -> GlobalState.NOTIFICATION_CHANNEL_SUSPENDED
            isHighPriority -> GlobalState.NOTIFICATION_CHANNEL_HIGH
            else -> GlobalState.NOTIFICATION_CHANNEL
        }
        val priority = if (isSuspended || isHighPriority) NotificationCompat.PRIORITY_HIGH else NotificationCompat.PRIORITY_LOW

        NotificationCompat.Builder(this@createBettboxNotificationBuilder, channelId).apply {
            setSmallIcon(R.drawable.ic)
            if (largeIconBitmap != null) {
                setLargeIcon(largeIconBitmap)
            }
            setContentTitle("Gamebox")
            setContentIntent(pendingIntent)
            setCategory(NotificationCompat.CATEGORY_SERVICE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                foregroundServiceBehavior = FOREGROUND_SERVICE_IMMEDIATE
            }
            setOngoing(true)
            setShowWhen(true)
            setOnlyAlertOnce(true)
            setPriority(priority)
        }
    }

fun Service.ensureNotificationChannel(
    isSuspended: Boolean = GlobalState.isSmartStopped,
    isHighPriority: Boolean = GlobalState.isNotificationHighPriority
) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
    val manager = getSystemService(NotificationManager::class.java) ?: return
    val channelId = when {
        isSuspended -> GlobalState.NOTIFICATION_CHANNEL_SUSPENDED
        isHighPriority -> GlobalState.NOTIFICATION_CHANNEL_HIGH
        else -> GlobalState.NOTIFICATION_CHANNEL
    }
    val channel = manager.getNotificationChannel(channelId)
    if (channel == null) {
        val importance = when {
            isSuspended -> NotificationManager.IMPORTANCE_DEFAULT
            isHighPriority -> NotificationManager.IMPORTANCE_HIGH
            else -> NotificationManager.IMPORTANCE_LOW
        }
        val name = when {
            isSuspended -> "Gamebox Suspended Service"
            isHighPriority -> "Gamebox High Priority Service"
            else -> "Gamebox Service"
        }
        val newChannel = NotificationChannel(channelId, name, importance).apply {
            setShowBadge(false)
            if (isSuspended || isHighPriority) {
                setSound(null, null)
                enableVibration(false)
            }
        }
        manager.createNotificationChannel(newChannel)
    }
}

@SuppressLint("ForegroundServiceType")
fun Service.startForeground(notification: Notification, useSpecialType: Boolean = true) {
    ensureNotificationChannel(GlobalState.isSmartStopped, GlobalState.isNotificationHighPriority)

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
        runCatching {
            startForeground(GlobalState.NOTIFICATION_ID, notification)
        }.onFailure { fallbackErr ->
            android.util.Log.e("BaseServiceInterface", "startForeground fallback failed: ${fallbackErr.message}")
        }
    }
}
