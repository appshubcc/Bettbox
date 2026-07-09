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
import android.os.IBinder
import androidx.core.content.getSystemService
import com.appshub.bettbox.BettboxApplication
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.RunState
import com.appshub.bettbox.core.Core
import com.appshub.bettbox.extensions.awaitResult
import com.appshub.bettbox.extensions.asSocketAddressText
import com.appshub.bettbox.extensions.resolveDns
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

    @Volatile
    private var quickResponseEnabled = false
    private var quickResponseJob: Job? = null
    private var lastNetworkType: Int? = null
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

            "setSmartStopped" -> {
                val value = call.argument<Boolean>("value") ?: false
                GlobalState.isSmartStopped = value
                result.success(true)
            }

            "isSmartStopped" -> {
                result.success(GlobalState.isSmartStopped)
            }

            "smartStop" -> {
                handleSmartStop()
                result.success(true)
            }

            "smartResume" -> {
                val data = call.argument<String>("data")
                result.success(handleSmartResume(Gson().fromJson(data, VpnOptions::class.java)))
            }
            
            "setQuickResponse" -> {
                quickResponseEnabled = call.argument<Boolean>("enabled") ?: false
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
    
    fun setQuickResponse(enabled: Boolean) {
        quickResponseEnabled = enabled
    }

    fun getLocalIpAddresses(): List<String> = runCatching {
        networks.flatMap { network ->
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
    private fun getCurrentDns(): String {
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
            handleNetworkChange()
        }

        override fun onLost(network: Network) {
            networks.remove(network)
            networkDnsMap.remove(network)
            onUpdateNetwork()
            handleNetworkChange()
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

    private fun registerNetworkCallback() {
        if (!networkCallbackRegistered.compareAndSet(false, true)) return
        runCatching {
            networks.clear()
            connectivity?.registerNetworkCallback(request, callback)
        }.onFailure {
            networkCallbackRegistered.set(false)
            android.util.Log.e("VpnPlugin", "Failed to register network callback: ${it.message}")
        }
    }

    private fun unRegisterNetworkCallback() {
        if (!networkCallbackRegistered.compareAndSet(true, false)) return
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
    
    private fun handleNetworkChange() {
        val currentNetworkType = getCurrentNetworkType()
        if (lastNetworkType == null) {
            lastNetworkType = currentNetworkType
            return
        }

        if (currentNetworkType != lastNetworkType) {
            lastNetworkType = currentNetworkType

            ServicePlugin.notifyNetworkChanged()

            if (!quickResponseEnabled) return

            quickResponseJob?.cancel()
            quickResponseJob = scope.launch {
                delay(500)
                if (GlobalState.currentRunState == RunState.START) {
                    android.util.Log.d("VpnPlugin", "Quick Response: Network changed, notifying Dart")
                    ServicePlugin.notifyQuickResponse()
                }
            }
        }
    }

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
    
    private fun getCurrentNetworkType(): Int {
        val activeNetwork = connectivity?.activeNetwork ?: return -1
        val caps = connectivity?.getNetworkCapabilities(activeNetwork) ?: return -1
        return when {
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> 1
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> 2
            caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> 3
            else -> 0
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
    }

    fun updateNotificationIcon() {
        scope.launch {
            runCatching {
                (bettBoxService as? BettboxService)?.resetNotificationBuilder()
                (bettBoxService as? BettboxVpnService)?.resetNotificationBuilder()
                bettBoxService?.startForeground()
            }.onFailure {
                android.util.Log.e("VpnPlugin", "updateNotificationIcon error: ${it.message}")
            }
        }
    }

    fun updateNotificationSpeed(profileName: String, speedInfo: String) {
        scope.launch {
            runCatching {
                (bettBoxService as? BettboxVpnService)?.updateNotificationSpeed(profileName, speedInfo)
            }.onFailure {
                android.util.Log.e("VpnPlugin", "updateNotificationSpeed error: ${it.message}")
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
                val prepareIntent = try {
                    android.net.VpnService.prepare(BettboxApplication.getAppContext())
                } catch (e: Exception) {
                    null
                }

                if (prepareIntent != null) {
                    android.util.Log.w("VpnPlugin", "VPN permission required before start")
                    GlobalState.updateRunState(RunState.STOP)
                    withContext(Dispatchers.Main) {
                        GlobalState.getCurrentAppPlugin()?.requestVpnPermission {
                            handleStartService()
                        }
                    }
                    return@launch
                }

                val currentOptions = options
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
                    GlobalState.updateRunState(RunState.START)
                    lastStartForegroundParams = null
                    true
                }

                if (!startAllowed || currentOptions == null) return@launch

                performStartCore(currentOptions, retry = true, notifyOnFailure = true)
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

        com.appshub.bettbox.core.Core.startTun(
            fd = fd ?: 0,
            protect = this@VpnPlugin::protect,
            resolverProcess = this@VpnPlugin::resolverProcess,
        )

        GlobalState.runLock.withLock {
            if (GlobalState.currentRunState != RunState.START) {
                Core.stopTun()
                return@withLock
            }
            scope.launch { startForeground() }
            if (currentOptions.dozeSuspend) {
                suspendModule?.uninstall()
                suspendModule = SuspendModule(BettboxApplication.getAppContext())
                suspendModule?.install()
            }
        }
        onUpdateNetwork()
    }

    private fun protect(fd: Int): Boolean = runCatching {
        (bettBoxService as? BettboxVpnService)?.protect(fd) == true
    }.getOrElse {
        android.util.Log.e("VpnPlugin", "protect error: ${it.message}")
        false
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
            GlobalState.updateIsStopping(true)
            GlobalState.updateRunState(RunState.STOP)
            ServicePlugin.notifyRunStateChanged(RunState.STOP)
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
        scope.launch {
            startForeground()
        }
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

            performStartCore(options, retry = false, notifyOnFailure = false)
        }
        return true
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