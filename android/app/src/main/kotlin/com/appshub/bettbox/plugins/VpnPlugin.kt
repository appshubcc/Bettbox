package com.appshub.bettbox.plugins

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import android.widget.Toast
import androidx.core.content.getSystemService
import com.appshub.bettbox.BettboxApplication
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.RunState
import com.appshub.bettbox.core.Core
import com.appshub.bettbox.extensions.awaitResult
import com.appshub.bettbox.extensions.asSocketAddressText
import com.appshub.bettbox.extensions.resolveDns
import com.appshub.bettbox.extensions.trafficSpeedInfo
import com.appshub.bettbox.models.StartForegroundParams
import com.appshub.bettbox.models.VpnOptions
import com.appshub.bettbox.modules.SuspendModule
import com.appshub.bettbox.services.BaseServiceInterface
import com.appshub.bettbox.services.BettboxService
import com.appshub.bettbox.services.BettboxVpnService
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import java.util.Collections
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import java.net.Inet4Address
import java.net.InetSocketAddress
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.concurrent.withLock

data object VpnPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    @Volatile
    private var bettBoxService: BaseServiceInterface? = null
    @Volatile
    private var options: VpnOptions? = null

    @Volatile
    private var isBind = false
    private val isBinding = AtomicBoolean(false)

    private var job = SupervisorJob()
    private var scope = CoroutineScope(Dispatchers.Default + job as kotlin.coroutines.CoroutineContext)
    private var lastStartForegroundParams: StartForegroundParams? = null
    private val uidPageNameMap = ConcurrentHashMap<Int, String>()
    private var suspendModule: SuspendModule? = null

    private var speedTickerJob: Job? = null
    private val speedTickerLock = Any()

    private var defaultNetwork: Network? = null
    private var defaultNetworkTracked = false
    @Volatile
    private var defaultNetworkChangedAt = 0L
    @Volatile
    private var tunStartedAt = 0L
    @Volatile
    private var quickResponseAt = 0L
    private var lastDns = ""

    val networks: MutableSet<Network> = Collections.newSetFromMap(ConcurrentHashMap())

    private val connectivity by lazy {
        BettboxApplication.getAppContext().getSystemService<ConnectivityManager>()
    }

    private var bindTimeoutJob: Job? = null
    private val attachedMessengers = Collections.newSetFromMap(ConcurrentHashMap<BinaryMessenger, Boolean>())
    private val channelMap = ConcurrentHashMap<BinaryMessenger, MethodChannel>()
    private val activeChannels = CopyOnWriteArrayList<MethodChannel>()
    private val networkCallbackRegistered = AtomicBoolean(false)

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            bindTimeoutJob?.cancel()
            bindTimeoutJob = null
            isBind = true
            isBinding.set(false)
            bettBoxService = when (service) {
                is BettboxVpnService.LocalBinder -> service.getService()
                is BettboxService.LocalBinder -> service.getService()
                else -> throw Exception("invalid binder")
            }
            handleStartService()
        }

        override fun onServiceDisconnected(arg: ComponentName) {
            isBind = false
            isBinding.set(false)
            bettBoxService = null
            if (GlobalState.currentRunState == RunState.START) {
                android.util.Log.w("VpnPlugin", "Service unexpectedly disconnected while running, syncing state")
                GlobalState.updateRunState(RunState.STOP)
                ServicePlugin.notifyVpnStartFailed()
                ServicePlugin.notifyRunStateChanged(RunState.STOP)
            }
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val isFirstAttach = attachedMessengers.isEmpty()
        attachedMessengers.add(flutterPluginBinding.binaryMessenger)

        if (job.isCancelled) {
            job = SupervisorJob()
            scope = CoroutineScope(Dispatchers.Default + job as kotlin.coroutines.CoroutineContext)
        }

        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vpn")
        channel.setMethodCallHandler(this)
        channelMap[flutterPluginBinding.binaryMessenger] = channel
        activeChannels.add(channel)

        if (isFirstAttach) {
            scope.launch { registerNetworkCallback() }
        }

        scope.launch {
            var dns = when {
                lastDns.isNotBlank() -> lastDns
                else -> getCurrentDns()
            }
            if (dns.isBlank()) {
                delay(1000)
                dns = getCurrentDns()
                if (dns.isNotBlank()) lastDns = dns
            }
            withContext(Dispatchers.Main) {
                runCatching {
                    channel.invokeMethod("dnsChanged", dns)
                }
            }
        }

        if (GlobalState.currentRunState == RunState.START && bettBoxService == null) {
            android.util.Log.d("VpnPlugin", "VPN is running but service connection lost, rebinding...")
            options?.let { bindService() }
        }
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        attachedMessengers.remove(flutterPluginBinding.binaryMessenger)
        channelMap.remove(flutterPluginBinding.binaryMessenger)?.let { channel ->
            channel.setMethodCallHandler(null)
            activeChannels.remove(channel)
        }

        if (attachedMessengers.isEmpty()) {
            unRegisterNetworkCallback()
            job.cancel()
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                try {
                    val data = call.argument<String>("data")
                    if (data == null) {
                        result.error("INVALID_ARGUMENT", "data parameter is required", null)
                        return
                    }
                    val vpnOptions = Gson().fromJson(data, VpnOptions::class.java)
                    result.success(handleStart(vpnOptions))
                } catch (e: Exception) {
                    android.util.Log.e("VpnPlugin", "Failed to start VPN: ${e.message}")
                    result.error("PARSE_ERROR", "Failed to parse VpnOptions: ${e.message}", null)
                }
            }

            "stop" -> {
                handleStop()
                result.success(true)
            }

            "getLocalIpAddresses" -> {
                result.success(getLocalIpAddresses())
            }

            "getLocalGateways" -> {
                result.success(getLocalGateways())
            }

            "getCurrentDns" -> {
                result.success(getCurrentDns())
            }

            "hasPhysicalNetwork" -> {
                result.success(getActivePhysicalNetworks().isNotEmpty())
            }

            "quickResponse" -> {
                handleQuickResponse()
                result.success(true)
            }

            "isSmartStopped" -> {
                result.success(GlobalState.isSmartStopped)
            }

            "isSmartStopOverride" -> {
                result.success(GlobalState.smartStopOverride)
            }

            "clearSmartStopOverride" -> {
                GlobalState.smartStopOverride = false
                result.success(true)
            }

            "smartStop" -> {
                handleSmartStop()
                result.success(true)
            }

            "smartResume" -> {
                val data = call.argument<String>("data")
                result.success(handleSmartResume(Gson().fromJson(data, VpnOptions::class.java)))
            }

            "updateNotificationSpeed" -> {
                handleUpdateNotificationSpeed(
                    call.argument<String>("profileName") ?: "",
                    call.argument<String>("speedInfo") ?: ""
                )
                result.success(true)
            }

            "status" -> {
                result.success(GlobalState.currentRunState == RunState.START)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getActivePhysicalNetworks(): Set<Network> {
        val current = networks
        if (current.isNotEmpty()) return current

        val cm = connectivity ?: return emptySet()
        val isPhysical: (Network) -> Boolean = { net ->
            cm.getNetworkCapabilities(net)?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == false
        }

        val available = cm.allNetworks.filter(isPhysical).toSet()
        if (available.isNotEmpty()) return available

        return cm.activeNetwork?.takeIf(isPhysical)?.let { setOf(it) } ?: emptySet()
    }

    private fun getLanNetworks(): List<Network> {
        val cm = connectivity ?: return emptyList()
        return getActivePhysicalNetworks().filter { network ->
            cm.getNetworkCapabilities(network)?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == false
        }
    }

    fun getLocalIpAddresses(): List<String> = runCatching {
        getLanNetworks().flatMap { network ->
            connectivity?.getLinkProperties(network)
                ?.linkAddresses
                ?.mapNotNull { it.address }
                ?.filter { !it.isLoopbackAddress && it.hostAddress?.contains(":") == false }
                ?.mapNotNull { it.hostAddress }
                ?: emptyList()
        }
    }.getOrElse {
        android.util.Log.e("VpnPlugin", "getLocalIpAddresses error: ${it.message}")
        emptyList()
    }

    fun getLocalGateways(): List<String> = runCatching {
        getLanNetworks().flatMap { network ->
            connectivity?.getLinkProperties(network)
                ?.routes
                ?.filter { it.isDefaultRoute() }
                ?.mapNotNull { it.gateway }
                ?.filter {
                    !it.isLoopbackAddress && !it.isAnyLocalAddress &&
                        it.hostAddress?.contains(":") == false
                }
                ?.mapNotNull { it.hostAddress }
                ?: emptyList()
        }
    }.getOrElse {
        android.util.Log.e("VpnPlugin", "getLocalGateways error: ${it.message}")
        emptyList()
    }

    private val physicalTransports = listOf(
        NetworkCapabilities.TRANSPORT_ETHERNET to "Ethernet",
        NetworkCapabilities.TRANSPORT_WIFI to "Wi-Fi",
        NetworkCapabilities.TRANSPORT_CELLULAR to "Cellular",
    )

    private fun getDefaultPhysicalNetwork(): Network? {
        val cm = connectivity ?: return null
        val active = cm.activeNetwork
        val activeCaps = active?.let { cm.getNetworkCapabilities(it) }
        if (active != null && activeCaps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == false) {
            return active
        }
        return getActivePhysicalNetworks().maxByOrNull { network ->
            val caps = cm.getNetworkCapabilities(network) ?: return@maxByOrNull -1
            val index = physicalTransports.indexOfFirst { caps.hasTransport(it.first) }
            var score = if (index < 0) 0 else physicalTransports.size - index
            if (caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)) score += 4
            if (index >= 0 && activeCaps?.hasTransport(physicalTransports[index].first) == true) score += 8
            score
        }
    }

    fun getNetworkInfo(): Map<String, Any> = runCatching {
        val cm = connectivity
        val network = getDefaultPhysicalNetwork()
        val caps = network?.let { cm?.getNetworkCapabilities(it) }
        val link = network?.let { cm?.getLinkProperties(it) }
        val addresses = link?.linkAddresses
            ?.map { it.address }
            ?.filter { !it.isLoopbackAddress && !it.isLinkLocalAddress }
            .orEmpty()
        val gateway = link?.routes
            ?.filter { it.isDefaultRoute() }
            ?.mapNotNull { it.gateway }
            ?.firstOrNull { it is Inet4Address && !it.isAnyLocalAddress }
        mapOf(
            "type" to (physicalTransports.firstOrNull { caps?.hasTransport(it.first) == true }?.second ?: ""),
            "interface" to (link?.interfaceName ?: ""),
            "ip" to ((addresses.firstOrNull { it is Inet4Address } ?: addresses.firstOrNull())?.hostAddress ?: ""),
            "gateway" to (gateway?.hostAddress ?: ""),
            "dns" to link?.dnsServers?.mapNotNull { it.hostAddress }.orEmpty(),
        )
    }.getOrElse {
        android.util.Log.e("VpnPlugin", "getNetworkInfo error: ${it.message}")
        emptyMap()
    }

    fun handleStart(options: VpnOptions): Boolean {
        onUpdateNetwork()
        if (options.enable != this.options?.enable) {
            this.bettBoxService = null
        }
        this.options = options
        when (options.enable) {
            true -> handleStartVpn()
            false -> handleStartService()
        }
        return true
    }

    private fun handleStartVpn() {
        GlobalState.getCurrentAppPlugin()?.requestVpnPermission {
            handleStartService()
        }
    }

    fun requestGc() {
        invokeDart("gc")
    }

    fun onUpdateNetwork() {
        val dns = getCurrentDns()
        if (dns == lastDns) return
        lastDns = dns
        invokeDart("dnsChanged", dns)
    }

    fun notifyScreenStateChanged(isOn: Boolean) {
        Core.screenStateChanged(isOn)
        invokeDart("screenStateChanged", isOn)
        ServicePlugin.notifyScreenStateChanged(isOn)
        if (isOn) {
            ensureSpeedTicker()
        } else {
            stopSpeedTicker()
        }
    }

    fun getCurrentDns(): String {
        val dnsSet = when {
            networkDnsMap.isNotEmpty() -> networkDnsMap.values.flatMap { it }
            else -> {
                val cm = connectivity
                val activeNetwork = cm?.activeNetwork
                activeNetwork?.let { cm.resolveDns(it) } ?: emptyList()
            }
        }.toSet()
        return when {
            dnsSet.isNotEmpty() -> dnsSet.joinToString(",")
            else -> getAllNetworksDns()
        }
    }

    private fun getAllNetworksDns(): String {
        return runCatching {
            connectivity?.allNetworks?.flatMap { network ->
                connectivity?.resolveDns(network) ?: emptyList()
            }?.filter { it.isNotBlank() }?.toSet()?.joinToString(",") ?: ""
        }.getOrElse { "" }
    }

    private val networkDnsMap = ConcurrentHashMap<Network, List<String>>()

    private val callback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            networks.add(network)
            invokeDart("networkChanged")
        }

        override fun onLost(network: Network) {
            networks.remove(network)
            networkDnsMap.remove(network)
            onUpdateNetwork()
            invokeDart("networkChanged")
        }

        override fun onLinkPropertiesChanged(network: Network, linkProperties: LinkProperties) {
            val dnsList = linkProperties.dnsServers.map { it.asSocketAddressText(53) }
            networkDnsMap[network] = dnsList
            onUpdateNetwork()
        }
    }

    private val request = NetworkRequest.Builder().apply {
        addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
        addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
    }.build()

    private val defaultNetworkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            handleDefaultNetworkChanged(network)
        }

        override fun onLost(network: Network) {
            if (network == defaultNetwork) defaultNetwork = null
        }
    }

    private fun registerNetworkCallback() {
        if (!networkCallbackRegistered.compareAndSet(false, true)) return
        runCatching {
            networks.clear()
            connectivity?.registerNetworkCallback(request, callback)
        }.onFailure {
            networkCallbackRegistered.set(false)
            android.util.Log.e("VpnPlugin", "Failed to register network callback: ${it.message}")
            return
        }
        registerDefaultNetworkCallback()
    }

    private fun registerDefaultNetworkCallback() {
        val cm = connectivity ?: return
        val handler = Handler(Looper.getMainLooper())
        defaultNetwork = null
        defaultNetworkTracked = false
        runCatching {
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
                    cm.registerBestMatchingNetworkCallback(request, defaultNetworkCallback, handler)
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.P ->
                    cm.requestNetwork(request, defaultNetworkCallback, handler)
                else -> cm.registerDefaultNetworkCallback(defaultNetworkCallback, handler)
            }
        }.onFailure {
            android.util.Log.e("VpnPlugin", "Failed to register default network callback: ${it.message}")
        }
    }

    private fun unRegisterNetworkCallback() {
        if (!networkCallbackRegistered.compareAndSet(true, false)) return
        runCatching {
            connectivity?.unregisterNetworkCallback(defaultNetworkCallback)
        }
        runCatching {
            connectivity?.unregisterNetworkCallback(callback)
        }.onFailure {
            android.util.Log.e("VpnPlugin", "Failed to unregister network callback: ${it.message}")
        }.also {
            networks.clear()
            networkDnsMap.clear()
            onUpdateNetwork()
        }
    }

    private fun handleDefaultNetworkChanged(network: Network) {
        val changed = defaultNetworkTracked && network != defaultNetwork
        defaultNetwork = network
        defaultNetworkTracked = true
        if (!changed) return

        defaultNetworkChangedAt = SystemClock.elapsedRealtime()
        ServicePlugin.notifyNetworkChanged()
        invokeDart("networkChanged", true)
    }

    private fun handleQuickResponse() {
        if (GlobalState.currentRunState != RunState.START) return
        if (defaultNetworkChangedAt <= maxOf(tunStartedAt, quickResponseAt)) return
        quickResponseAt = SystemClock.elapsedRealtime()
        android.util.Log.d("VpnPlugin", "Quick Response: Default network changed")
        scope.launch { Core.onNetworkChanged() }
    }

    fun requestSmartAutoStopCheck() = invokeDart("networkChanged")

    private fun invokeDart(method: String, arguments: Any? = null) {
        if (activeChannels.isEmpty()) return
        scope.launch {
            withContext(Dispatchers.Main) {
                activeChannels.forEach { channel ->
                    runCatching { channel.invokeMethod(method, arguments) }
                        .onFailure {
                            android.util.Log.w("VpnPlugin", "invokeDart($method) failed: ${it.message}")
                        }
                }
            }
        }
    }
    
    private suspend fun startForeground() {
        val shouldUpdate = GlobalState.runLock.withLock {
            GlobalState.currentRunState == RunState.START || GlobalState.isSmartStopped
        }
        if (!shouldUpdate) return

        try {
            bettBoxService?.startForeground()
        } catch (e: Exception) {
            android.util.Log.e("VpnPlugin", "startForeground error: ${e.message}")
        }
        ensureSpeedTicker()
    }

    fun updateNotificationIcon() {
        scope.launch {
            runCatching {
                val context = BettboxApplication.getAppContext()
                val notificationManager = context.getSystemService(android.app.NotificationManager::class.java)
                notificationManager?.cancel(GlobalState.NOTIFICATION_ID)
                (bettBoxService as? BettboxService)?.resetNotificationBuilder()
                (bettBoxService as? BettboxVpnService)?.resetNotificationBuilder()
                bettBoxService?.startForeground()
            }.onFailure {
                android.util.Log.e("VpnPlugin", "updateNotificationIcon error: ${it.message}")
            }
        }
    }

    fun handleUpdateNotificationSpeed(profileName: String, speedInfo: String) {
        if (profileName != GlobalState.currentProfileName ||
            !GlobalState.isSpeedNotificationEnabled
        ) {
            GlobalState.currentProfileName = profileName
            GlobalState.isSpeedNotificationEnabled = true
        }
        updateNotificationSpeed(profileName, speedInfo)
        ensureSpeedTicker()
    }

    private fun isInteractive(): Boolean =
        BettboxApplication.getAppContext().getSystemService<PowerManager>()?.isInteractive != false

    private fun ensureSpeedTicker() {
        synchronized(speedTickerLock) {
            if (!GlobalState.isSpeedNotificationEnabled) return
            if (speedTickerJob?.isActive == true) return
            speedTickerJob = scope.launch {
                while (isActive) {
                    delay(1000)
                    if (!GlobalState.isSpeedNotificationEnabled ||
                        GlobalState.currentRunState != RunState.START ||
                        bettBoxService == null ||
                        !isInteractive()
                    ) {
                        break
                    }
                    val speedInfo = Core.trafficJson()?.let(::trafficSpeedInfo) ?: continue
                    updateNotificationSpeed(GlobalState.currentProfileName, speedInfo)
                }
            }
        }
    }

    private fun stopSpeedTicker() {
        synchronized(speedTickerLock) {
            speedTickerJob?.cancel()
            speedTickerJob = null
        }
    }

    fun updateNotificationSpeed(profileName: String, speedInfo: String) {
        scope.launch {
            runCatching {
                when (val service = bettBoxService) {
                    is BettboxVpnService -> service.updateNotificationSpeed(profileName, speedInfo)
                    is BettboxService -> service.updateNotificationSpeed(profileName, speedInfo)
                    else -> Unit
                }
            }.onFailure {
                android.util.Log.e("VpnPlugin", "updateNotificationSpeed error: ${it.message}")
            }
        }
    }

    fun restoreNotification() {
        stopSpeedTicker()
        scope.launch {
            runCatching {
                when (val service = bettBoxService) {
                    is BettboxVpnService -> service.restoreNotification()
                    is BettboxService -> service.restoreNotification()
                    else -> Unit
                }
            }.onFailure {
                android.util.Log.e("VpnPlugin", "restoreNotification error: ${it.message}")
            }
        }
    }

    fun setHighPriorityNotification(enabled: Boolean) {
        GlobalState.isNotificationHighPriority = enabled
        (bettBoxService as? BettboxService)?.resetNotificationBuilder()
        (bettBoxService as? BettboxVpnService)?.resetNotificationBuilder()
        if (GlobalState.currentRunState == RunState.START) {
            scope.launch {
                startForeground()
            }
        }
    }

    fun getStatus(): Boolean {
        return GlobalState.runLock.withLock {
            GlobalState.currentRunState == RunState.START && bettBoxService != null
        }
    }

    private fun handleStartService() {
        if (GlobalState.isCurrentlyStopping()) {
            android.util.Log.w("VpnPlugin", "VPN is in stopping state, ignore start request")
            return
        }
        if (bettBoxService == null) {
            bindService()
            return
        }
        
        scope.launch {
            try {
                if (options?.enable == true) {
                    val prepareIntent = try {
                        android.net.VpnService.prepare(BettboxApplication.getAppContext())
                    } catch (e: Exception) {
                        null
                    }

                    if (prepareIntent != null) {
                        android.util.Log.w("VpnPlugin", "VPN permission required before start")
                        GlobalState.updateRunState(RunState.STOP)
                        ServicePlugin.notifyVpnStartFailed()
                        return@launch
                    }
                }

                val currentOptions = options
                var wasSmartStopped = false
                val startAllowed = GlobalState.runLock.withLock {
                    if (GlobalState.currentRunState == RunState.START) {
                        android.util.Log.d("VpnPlugin", "Service already running, refreshing notification")
                        scope.launch { startForeground() }
                        return@withLock false
                    }
                    if (currentOptions == null) {
                        android.util.Log.e("VpnPlugin", "Start failed: options is null")
                        GlobalState.updateRunState(RunState.STOP)
                        return@withLock false
                    }
                    wasSmartStopped = GlobalState.isSmartStopped
                    GlobalState.isSmartStopped = false
                    GlobalState.smartStopOverride = wasSmartStopped
                    GlobalState.updateRunState(RunState.START)
                    lastStartForegroundParams = null
                    true
                }

                if (!startAllowed || currentOptions == null) return@launch

                performStartCore(currentOptions, retry = true, notifyOnFailure = true)
                requestSmartAutoStopCheck()
                if (wasSmartStopped) {
                    ServicePlugin.notifyNetworkChanged()
                }
            } catch (e: Exception) {
                android.util.Log.e("VpnPlugin", "Fatal error in start flow: ${e.message}")
                GlobalState.updateRunState(RunState.STOP)
            }
        }
    }

    private suspend fun performStartCore(
        currentOptions: VpnOptions,
        retry: Boolean,
        notifyOnFailure: Boolean
    ) {
        resumeCore()
        var fd: Int? = 0
        try {
            fd = bettBoxService?.start(currentOptions)
        } catch (e: Exception) {
            android.util.Log.e("VpnPlugin", "First start attempt failed: ${e.message}")
        }

        if (fd == null || (currentOptions.enable && fd <= 0)) {
            if (retry) {
                android.util.Log.w("VpnPlugin", "VPN establish failed, retrying...")
                delay(300)
                try {
                    fd = bettBoxService?.start(currentOptions)
                } catch (e: Exception) {
                    android.util.Log.e("VpnPlugin", "Retry start failed: ${e.message}")
                }
            }
        }

        if (fd == null || (currentOptions.enable && fd <= 0)) {
            android.util.Log.e("VpnPlugin", "VPN start failed after all attempts")
            GlobalState.runLock.withLock { GlobalState.updateRunState(RunState.STOP) }
            if (notifyOnFailure) {
                ServicePlugin.notifyVpnStartFailed()
            }
            return
        }

        val canStart = GlobalState.runLock.withLock {
            if (GlobalState.currentRunState != RunState.START) {
                bettBoxService?.stop()
                false
            } else true
        }
        if (!canStart) return

        tunStartedAt = SystemClock.elapsedRealtime()
        val tunStarted = com.appshub.bettbox.core.Core.startTun(
            fd = fd ?: 0,
            protect = this@VpnPlugin::protect,
            resolverProcess = this@VpnPlugin::resolverProcess,
        )
        if (!tunStarted) {
            android.util.Log.e("VpnPlugin", "Core startTun failed")
            GlobalState.runLock.withLock { GlobalState.updateRunState(RunState.STOP) }
            if (notifyOnFailure) {
                ServicePlugin.notifyVpnStartFailed()
            }
            return
        }

        GlobalState.runLock.withLock {
            if (GlobalState.currentRunState != RunState.START) {
                Core.stopTun()
                return@withLock
            }
            scope.launch {
                startForeground()
                startStickyService()
            }
            Core.screenStateChanged(isInteractive())
            if (currentOptions.dozeSuspend) {
                suspendModule?.uninstall()
                suspendModule = SuspendModule(BettboxApplication.getAppContext())
                suspendModule?.install()
            }
        }
        onUpdateNetwork()
    }

    private fun startStickyService() {
        GlobalState.runLock.withLock {
            if (GlobalState.currentRunState != RunState.START) return
            if (bettBoxService !is BettboxVpnService) return
            val context = BettboxApplication.getAppContext()
            runCatching {
                context.startService(Intent(context, BettboxVpnService::class.java))
            }.onFailure {
                android.util.Log.w("VpnPlugin", "startService error: ${it.message}")
            }
        }
    }

    private fun protect(fd: Int): Boolean {
        var retries = 0
        while (retries < 5) {
            val success = runCatching {
                (bettBoxService as? BettboxVpnService)?.protect(fd) == true
            }.getOrDefault(false)
            
            if (success) return true
            
            retries++
            if (retries < 5) {
                Thread.sleep(60)
            }
        }
        android.util.Log.e("VpnPlugin", "protect failed for fd $fd after retries")
        return false
    }

    private fun resolverProcess(
        protocol: Int,
        source: InetSocketAddress,
        target: InetSocketAddress,
        uid: Int,
    ): String = runCatching {
        val nextUid = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            connectivity?.getConnectionOwnerUid(protocol, source, target) ?: -1
        } else {
            uid
        }
        if (nextUid == -1) {
            return@runCatching ""
        }
        uidPageNameMap.getOrPut(nextUid) {
            BettboxApplication.getAppContext().packageManager?.getPackagesForUid(nextUid)
                ?.firstOrNull() ?: ""
        }
    }.getOrElse {
        android.util.Log.e("VpnPlugin", "resolverProcess error: ${it.message}")
        ""
    }

    fun handleStop(force: Boolean = false) {
        val serviceRef: BaseServiceInterface?
        val wasBound: Boolean
        val shouldForceStop: Boolean
        GlobalState.runLock.withLock {
            if (!force && GlobalState.currentRunState == RunState.STOP) return
            GlobalState.isSmartStopped = false
            GlobalState.smartStopOverride = false
            GlobalState.updateIsStopping(true)
            GlobalState.updateRunState(RunState.STOP)
            if (!force) {
                ServicePlugin.notifyRunStateChanged(RunState.STOP)
            }
            serviceRef = bettBoxService
            wasBound = isBind
            shouldForceStop = force || bettBoxService == null
        }

        suspendModule?.uninstall()
        suspendModule = null
        Core.stopTun()
        serviceRef?.stop()

        runCatching {
            if (wasBound) {
                BettboxApplication.getAppContext().unbindService(connection)
                isBind = false
            }
            bettBoxService = null
        }.onFailure {
            android.util.Log.e("VpnPlugin", "unbindService error: ${it.message}")
        }

        val context = BettboxApplication.getAppContext()
        if (shouldForceStop) {
            context.stopService(Intent(context, BettboxVpnService::class.java))
            context.stopService(Intent(context, BettboxService::class.java))
        }

        runCatching {
            context.getSystemService<android.app.NotificationManager>()
                ?.cancel(GlobalState.NOTIFICATION_ID)
        }.onFailure {
            android.util.Log.e("VpnPlugin", "cancel notification error: ${it.message}")
        }

        scope.launch {
            delay(300)
            GlobalState.updateIsStopping(false)
            delay(200)
            withContext(Dispatchers.Main) {
                GlobalState.handleTryDestroy()
            }
        }
    }

    fun handleSmartStop() {
        GlobalState.runLock.withLock {
            if (GlobalState.currentRunState == RunState.STOP) return
            GlobalState.updateRunState(RunState.STOP)
            GlobalState.isSmartStopped = true
        }
        suspendModule?.uninstall()
        suspendModule = null
        Core.stopTun()
        Core.suspended(true)
        (bettBoxService as? BettboxService)?.resetNotificationBuilder()
        (bettBoxService as? BettboxVpnService)?.resetNotificationBuilder()
        scope.launch {
            startForeground()
        }
        scope.launch(Dispatchers.Main) {
            Toast.makeText(BettboxApplication.getAppContext(), "Bettbox Suspended", Toast.LENGTH_SHORT).show()
        }
        ServicePlugin.notifyNetworkChanged()
    }

    fun handleSmartResume(options: VpnOptions): Boolean {
        scope.launch {
            val startAllowed = GlobalState.runLock.withLock {
                if (GlobalState.currentRunState == RunState.START) return@withLock false
                GlobalState.isSmartStopped = false
                this@VpnPlugin.options = options

                if (bettBoxService == null) {
                    bindService()
                    return@withLock false
                }

                GlobalState.updateRunState(RunState.START)
                lastStartForegroundParams = null
                true
            }
            if (!startAllowed) return@launch

            (bettBoxService as? BettboxService)?.resetNotificationBuilder()
            (bettBoxService as? BettboxVpnService)?.resetNotificationBuilder()
            performStartCore(options, retry = false, notifyOnFailure = false)
            withContext(Dispatchers.Main) {
                Toast.makeText(BettboxApplication.getAppContext(), "Bettbox Connected", Toast.LENGTH_SHORT).show()
            }
            ServicePlugin.notifyNetworkChanged()
        }
        return true
    }

    fun resumeCore() {
        Core.suspended(false)
    }

    private fun bindService() {
        if (!isBinding.compareAndSet(false, true)) return

        bindTimeoutJob?.cancel()
        bindTimeoutJob = scope.launch {
            delay(10_000L)
            if (isBinding.compareAndSet(true, false)) {
                android.util.Log.w("VpnPlugin", "bindService timeout (10s), resetting bind state")
                GlobalState.runLock.withLock {
                    if (GlobalState.currentRunState == RunState.PENDING) {
                        GlobalState.updateRunState(RunState.STOP)
                    }
                }
            }
        }

        try {
            if (isBind) {
                BettboxApplication.getAppContext().unbindService(connection)
                isBind = false
            }
            val intent = Intent(
                BettboxApplication.getAppContext(),
                if (options?.enable == true) BettboxVpnService::class.java else BettboxService::class.java
            )
            val res = BettboxApplication.getAppContext().bindService(intent, connection, Context.BIND_AUTO_CREATE)
            if (!res) {
                isBinding.set(false)
                bindTimeoutJob?.cancel()
                bindTimeoutJob = null
                android.util.Log.e("VpnPlugin", "bindService returned false (rejected by system)")
            }
        } catch (e: Exception) {
            isBinding.set(false)
            bindTimeoutJob?.cancel()
            bindTimeoutJob = null
            android.util.Log.e("VpnPlugin", "bindService error: ${e.message}")
        }
    }
}