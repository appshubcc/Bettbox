package com.appshub.bettbox.services

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ProxyInfo
import android.net.VpnService
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.Parcel
import android.os.PowerManager
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

    private var unlockReceiver: BroadcastReceiver? = null
    private val fairMemoryHelper = FairMemoryHelper(TAG)
    
    @Volatile
    private var isSpeedNotificationEnabled = false

    @Volatile
    private var lastNotificationText: String? = null

    @Volatile
    private var pendingSpeedProfile: String? = null

    @Volatile
    private var pendingSpeedInfo: String? = null

    override fun onCreate() {
        super.onCreate()
        GlobalState.initServiceEngine()

        unlockReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    Intent.ACTION_SCREEN_OFF -> {
                        GlobalState.getCurrentVPNPlugin()?.notifyScreenStateChanged(false)
                        return
                    }
                    Intent.ACTION_SCREEN_ON -> {
                        GlobalState.getCurrentVPNPlugin()?.notifyScreenStateChanged(true)
                    }
                }
                lastNotificationText = null
                resetNotificationBuilder()
                CoroutineScope(Dispatchers.Main).launch {
                    startForeground()
                }
            }
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_USER_PRESENT)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        registerReceiver(unlockReceiver, filter, if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) Context.RECEIVER_NOT_EXPORTED else 0)

        fairMemoryHelper.register(
            context = this,
            onTrim = { GlobalState.getCurrentVPNPlugin()?.requestGc() },
            onKill = { /* system will kill process; service has no extra state to save */ }
        )
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
                AccessControlMode.acceptSelected -> (ac.acceptList + packageName).forEach {
                    runCatching { addAllowedApplication(it) }
                }
                AccessControlMode.rejectSelected -> (ac.rejectList - packageName).forEach {
                    runCatching { addDisallowedApplication(it) }
                }
            }
        }

        setSession("Bettbox")
        setBlocking(false)
        if (Build.VERSION.SDK_INT >= 29) setMetered(false)
        if (options.allowBypass) allowBypass()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.systemProxy) {
            setHttpProxy(ProxyInfo.buildDirectProxy("127.0.0.1", options.port, options.bypassDomain))
        }

        val fd = runCatching { establish()?.detachFd() }.getOrElse { e ->
            Log.e(TAG, "Establish VPN exception: ${e.message}")
            null
        }
        if (fd != null && fd > 0) {
            return fd
        }
        Log.e(TAG, "Establish VPN rejected by system")
        -1
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "UPDATE_NOTIFICATION_SPEED") {
            val profileName = intent.getStringExtra("profileName") ?: ""
            val speedInfo = intent.getStringExtra("speedInfo") ?: ""
            isSpeedNotificationEnabled = true
            if (!GlobalState.isSmartStopped && hasStartedForeground) {
                CoroutineScope(Dispatchers.Main).launch {
                    updateNotificationSpeed(profileName, speedInfo)
                }
            }
        } else if (intent?.action == "RESTORE_NOTIFICATION") {
            isSpeedNotificationEnabled = false
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
        lastNotificationText = null

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
        val title: String
        val content: String
        if (GlobalState.isSmartStopped) {
            title = getString(R.string.core_suspended)
            content = getString(R.string.smart_auto_stop_service_running)
        } else {
            title = getString(R.string.core_connected)
            content = getString(R.string.service_running)
        }

        lastNotificationText = null
        val builder = notificationBuilder()
        val notification = builder
            .setContentTitle(title)
            .setContentText(content)
            .setStyle(null)
            .setTicker("$title: $content")
            .build()

        val isFirstTime = !hasStartedForeground
        if (isFirstTime) {
            hasStartedForeground = true
        }

        val pendingProfile = pendingSpeedProfile
        val pendingSpeed = pendingSpeedInfo
        if (isFirstTime && isSpeedNotificationEnabled && pendingProfile != null && pendingSpeed != null) {
            updateNotificationSpeed(pendingProfile, pendingSpeed)
            return
        }

        this.startForeground(notification, useSpecialType = !GlobalState.isSmartStopped)
    }

    @SuppressLint("ForegroundServiceType")
    internal suspend fun updateNotificationSpeed(profileName: String, speedInfo: String) {
        pendingSpeedProfile = profileName
        pendingSpeedInfo = speedInfo

        val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
        if (powerManager?.isInteractive == false) {
            return
        }

        if (GlobalState.isSmartStopped) {
            return
        }

        val combinedText = "$profileName\n$speedInfo"
        if (combinedText == lastNotificationText) {
            return
        }
        lastNotificationText = combinedText

        val builder = notificationBuilder()
        val notification = builder
            .setContentTitle(profileName)
            .setContentText(speedInfo)
            .setStyle(null)
            .setTicker("$profileName: $speedInfo")
            .build()

        if (hasStartedForeground) {
            runCatching {
                this.startForeground(notification, useSpecialType = !GlobalState.isSmartStopped)
            }.onFailure { Log.e(TAG, "updateNotificationSpeed startForeground error: ${it.message}") }
        }
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        if (level == 10 || level == 15 || level >= 40) {
            GlobalState.getCurrentVPNPlugin()?.requestGc()
        }
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
        unlockReceiver?.let {
            unregisterReceiver(it)
            unlockReceiver = null
        }
        fairMemoryHelper.unregister(this)
        super.onDestroy()
    }
}
