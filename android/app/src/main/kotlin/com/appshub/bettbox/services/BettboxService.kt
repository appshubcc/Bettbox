package com.appshub.bettbox.services

import android.annotation.SuppressLint
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.text.SpannableString
import android.text.Spanned
import android.text.style.RelativeSizeSpan
import androidx.core.app.NotificationCompat
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.R
import com.appshub.bettbox.models.VpnOptions

class BettboxService : Service(), BaseServiceInterface {

    @Volatile
    private var cachedBuilder: NotificationCompat.Builder? = null
    private val binder = LocalBinder()
    @Volatile
    private var hasStartedForeground = false

    inner class LocalBinder : Binder() {
        fun getService() = this@BettboxService
    }

    override suspend fun start(options: VpnOptions) = 0

    override fun stop() {
        hasStartedForeground = false

        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                stopForeground(true)
            }
        }.onFailure { android.util.Log.e("BettboxService", "Failed to stop foreground: ${it.message}") }

        runCatching {
            getSystemService(android.app.NotificationManager::class.java)
                ?.cancel(GlobalState.NOTIFICATION_ID)
        }.onFailure { android.util.Log.e("BettboxService", "Failed to cancel notification: ${it.message}") }

        stopSelf()
    }

    fun resetNotificationBuilder() {
        cachedBuilder = null
    }

    private suspend fun notificationBuilder() =
        cachedBuilder ?: createBettboxNotificationBuilder().also { cachedBuilder = it }

    @SuppressLint("ForegroundServiceType")
    override suspend fun startForeground() {
        ensureNotificationChannel()
        val title: String
        val content: String
        if (GlobalState.isSmartStopped) {
            title = getString(R.string.core_suspended)
            content = getString(R.string.smart_auto_stop_service_running)
        } else {
            title = getString(R.string.core_connected)
            content = getString(R.string.service_running)
        }

        val builder = notificationBuilder()

        val separator = " ‹ "
        val combinedText = "$title$separator$content"
        val spannable = SpannableString(combinedText).apply {
            val startIndex = title.length + separator.length
            if (startIndex in 1..combinedText.length) {
                setSpan(
                    RelativeSizeSpan(0.80f),
                    startIndex,
                    combinedText.length,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                )
            }
        }
        val notification = builder.setContentTitle(spannable)
            .setContentText(null)
            .setStyle(null)
            .setTicker(combinedText)
            .build()

        if (!hasStartedForeground) {
            this.startForeground(notification, useSpecialType = !GlobalState.isSmartStopped)
            hasStartedForeground = true
        } else {
            getSystemService(android.app.NotificationManager::class.java)?.notify(GlobalState.NOTIFICATION_ID, notification)
        }
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        GlobalState.getCurrentVPNPlugin()?.requestGc()
    }

    override fun onBind(intent: Intent): IBinder = binder

    override fun onDestroy() {
        stop()
        super.onDestroy()
    }
}
