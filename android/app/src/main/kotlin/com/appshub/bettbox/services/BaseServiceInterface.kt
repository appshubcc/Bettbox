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
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.toBitmap
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

suspend fun Service.createBettboxNotificationBuilder(
    isSuspended: Boolean = GlobalState.isSmartStopped,
    isHighPriority: Boolean = GlobalState.isNotificationHighPriority
): NotificationCompat.Builder =
    withContext(Dispatchers.IO) {
        val intent = (packageManager.getLaunchIntentForPackage(packageName) ?: Intent().apply {
            component = ComponentName(packageName, "com.appshub.bettbox.MainActivity")
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
        }).apply {
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

        val largeIconBitmap = if (isSuspended) {
            runCatching {
                ContextCompat.getDrawable(this@createBettboxNotificationBuilder, R.mipmap.ic_launcher)?.toBitmap()
            }.getOrNull()
        } else {
            null
        }

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
            setContentTitle("Bettbox")
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
            isSuspended -> "Bettbox Suspended Service"
            isHighPriority -> "Bettbox High Priority Service"
            else -> "Bettbox Service"
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
        if (Build.VERSION.SDK_INT >= 34 && type != 0) {
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
