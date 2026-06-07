package com.appshub.bettbox.services

import android.annotation.SuppressLint
import android.content.Intent
import android.net.ProxyInfo
import android.net.VpnService
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.Parcel
import android.util.Log
import androidx.core.app.NotificationCompat
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.extensions.getIpv4RouteAddress
import com.appshub.bettbox.extensions.getIpv6RouteAddress
import com.appshub.bettbox.extensions.toCIDR
import com.appshub.bettbox.models.AccessControlMode
import com.appshub.bettbox.models.VpnOptions
import com.appshub.bettbox.plugins.VpnPlugin
import com.appshub.bettbox.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class BettboxVpnService : VpnService(), BaseServiceInterface {
    companion object {
        private const val TAG = "BettboxVpnService"
    }

    @Volatile
    private var isStopped = false

    @Volatile
    private var hasStartedForeground = false

    override fun onCreate() {
        super.onCreate()
        GlobalState.initServiceEngine()
    }

    override suspend fun start(options: VpnOptions): Int = with(Builder()) {
        options.ipv4Address.takeIf { it.isNotEmpty() }?.let { ipv4 ->
            val cidr = ipv4.toCIDR()
            addAddress(cidr.address, cidr.prefixLength)
            Log.d("addAddress", "address: ${cidr.address} prefixLength:${cidr.prefixLength}")
            val routes = options.getIpv4RouteAddress()
            if (routes.isNotEmpty()) {
                runCatching { routes.forEach { addRoute(it.address, it.prefixLength) } }
                    .onFailure { addRoute("0.0.0.0", 0) }
            } else {
                addRoute("0.0.0.0", 0)
            }
        } ?: addRoute("0.0.0.0", 0)

        if (options.ipv6Address.isNotEmpty()) {
            runCatching {
                val cidr = options.ipv6Address.toCIDR()
                Log.d("addAddress6", "address: ${cidr.address} prefixLength:${cidr.prefixLength}")
                addAddress(cidr.address, cidr.prefixLength)
                val routes = options.getIpv6RouteAddress()
                if (routes.isNotEmpty()) {
                    runCatching { routes.forEach { addRoute(it.address, it.prefixLength) } }
                        .onFailure { addRoute("::", 0) }
                } else {
                    addRoute("::", 0)
                }
            }.onFailure { Log.d("addAddress6", "IPv6 is not supported.") }
        }

        if (options.dnsServerAddress.isNotBlank()) {
            runCatching { addDnsServer(options.dnsServerAddress) }
                .onFailure { Log.e(TAG, "Invalid DNS: ${options.dnsServerAddress}") }
        }

        setMtu(options.mtu.coerceIn(1280..65535).takeIf { it > 0 } ?: 1480)

        options.accessControl.takeIf { it.enable }?.let { ac ->
            when (ac.mode) {
                AccessControlMode.acceptSelected -> (ac.acceptList + packageName).forEach { addAllowedApplication(it) }
                AccessControlMode.rejectSelected -> (ac.rejectList - packageName).forEach { addDisallowedApplication(it) }
            }
        }

        setSession("Bettbox")
        setBlocking(false)
        if (Build.VERSION.SDK_INT >= 29) setMetered(false)
        if (options.allowBypass) allowBypass()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.systemProxy) {
            setHttpProxy(ProxyInfo.buildDirectProxy("127.0.0.1", options.port, options.bypassDomain))
        }

        establish()?.detachFd()?.also { return it }
        Log.e(TAG, "Establish VPN rejected by system")
        -1
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "UPDATE_NOTIFICATION_SPEED") {
            val profileName = intent.getStringExtra("profileName") ?: ""
            val speedInfo = intent.getStringExtra("speedInfo") ?: ""
            if (!GlobalState.isSmartStopped && hasStartedForeground) {
                CoroutineScope(Dispatchers.Main).launch {
                    updateNotificationSpeed(profileName, speedInfo)
                }
            }
        } else if (intent?.action == "RESTORE_NOTIFICATION") {
            if (hasStartedForeground) {
                CoroutineScope(Dispatchers.Main).launch {
                    startForeground()
                }
            }
        }
        return START_STICKY
    }
    override fun stop() {
        if (isStopped) return
        isStopped = true
        hasStartedForeground = false

        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                stopForeground(true)
            }
        }.onFailure { Log.e(TAG, "Failed to stop foreground: ${it.message}") }

        runCatching {
            getSystemService(android.app.NotificationManager::class.java)
                ?.cancel(GlobalState.NOTIFICATION_ID)
        }.onFailure { Log.e(TAG, "Failed to cancel notification: ${it.message}") }

        stopSelf()
    }

    @Volatile
    private var cachedBuilder: NotificationCompat.Builder? = null

    fun resetNotificationBuilder() {
        cachedBuilder = null
    }

    private suspend fun notificationBuilder(): NotificationCompat.Builder {
        if (cachedBuilder == null) {
            cachedBuilder = createBettboxNotificationBuilder()
        }
        return cachedBuilder!!
    }

    @SuppressLint("ForegroundServiceType")
    override suspend fun startForeground() {
        ensureNotificationChannel()
        val title:
        String
        val content: String
        if (GlobalState.isSmartStopped) {
            title = getString(R.string.core_suspended)
            content = getString(R.string.smart_auto_stop_service_running)
        } else {
            title = getString(R.string.core_connected)
            content = getString(R.string.service_running)
        }

        val builder = notificationBuilder()

        val separator = " ︙ "
        val combinedText = "$title$separator$content"
        val spannable = android.text.SpannableString(combinedText)
        val startIndex = title.length + separator.length
        if (startIndex in 1..combinedText.length) {
            spannable.setSpan(
                android.text.style.RelativeSizeSpan(0.80f),
                startIndex,
                combinedText.length,
                android.text.Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
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
            runCatching {
                getSystemService(android.app.NotificationManager::class.java)?.notify(GlobalState.NOTIFICATION_ID, notification)
            }.onFailure { Log.e(TAG, "startForeground notify error: ${it.message}") }
        }
    }

    @SuppressLint("ForegroundServiceType")
    private suspend fun updateNotificationSpeed(profileName: String, speedInfo: String) {
        val builder = notificationBuilder()
        val separator = " ︙ "
        val combinedText = "$profileName$separator$speedInfo"
        val spannable = android.text.SpannableString(combinedText)
        val startIndex = profileName.length + separator.length
        if (startIndex in 1..combinedText.length) {
            spannable.setSpan(
                android.text.style.RelativeSizeSpan(0.80f),
                startIndex,
                combinedText.length,
                android.text.Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
        val notification = builder.setContentTitle(spannable)
            .setContentText(null)
            .setStyle(null)
            .setTicker(combinedText)
            .build()
            
        if (hasStartedForeground) {
            runCatching {
                getSystemService(android.app.NotificationManager::class.java)?.notify(GlobalState.NOTIFICATION_ID, notification)
            }.onFailure { Log.e(TAG, "updateNotificationSpeed notify error: ${it.message}") }
        }
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        GlobalState.getCurrentVPNPlugin()?.requestGc()
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): BettboxVpnService = this@BettboxVpnService

        override fun onTransact(code: Int, data: Parcel, reply: Parcel?, flags: Int): Boolean =
            runCatching {
                super.onTransact(code, data, reply, flags).also { success ->
                    if (!success) GlobalState.getCurrentTilePlugin()?.handleStop()
                }
            }.getOrElse { Log.e(TAG, "onTransact failed: ${it.message}"); false }
    }

    override fun onBind(intent: Intent?): IBinder? {
        if (intent?.action == VpnService.SERVICE_INTERFACE) {
            return super.onBind(intent)
        }
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        super.onUnbind(intent)
        return true
    }

    override fun onRevoke() {
        runCatching {
            VpnPlugin.handleStop()
            getSystemService(android.app.NotificationManager::class.java)
                ?.cancel(GlobalState.NOTIFICATION_ID)
        }.onFailure { Log.e(TAG, "onRevoke error: ${it.message}") }
        super.onRevoke()
    }

    override fun onDestroy() {
        stop()
        super.onDestroy()
    }
}
