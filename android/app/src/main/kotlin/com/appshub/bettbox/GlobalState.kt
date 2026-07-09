package com.appshub.bettbox

import android.os.SystemClock
import com.appshub.bettbox.plugins.AppPlugin
import com.appshub.bettbox.plugins.ServicePlugin
import com.appshub.bettbox.plugins.TilePlugin
import com.appshub.bettbox.plugins.VpnPlugin
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

enum class RunState {
    START,
    PENDING,
    STOP
}

object GlobalState {
    val runLock = ReentrantLock()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    const val NOTIFICATION_CHANNEL = "Bettbox"
    const val NOTIFICATION_ID = 1

    private const val TOGGLE_DEBOUNCE_MS = 1000L
    private const val PENDING_TIMEOUT_MS = 5000L
    private const val STOP_LOCK_TIMEOUT_MS = 5000L

    @Volatile
    private var lastToggleAt = 0L

    @Volatile
    var currentRunState: RunState = RunState.STOP
        private set

    private val _runState = MutableStateFlow(RunState.STOP)
    val runState = _runState.asStateFlow()

    private var pendingTimeoutJob: Job? = null

    var flutterEngine: FlutterEngine? = null
    private var serviceEngine: FlutterEngine? = null

    @Volatile
    var isSmartStopped = false

    @Volatile
    var isStopping = false

    @Volatile
    var currentProfileName: String = ""

    @Volatile
    var isSpeedNotificationEnabled: Boolean = false

    fun updateRunState(newState: RunState) {
        if (newState != RunState.PENDING) {
            pendingTimeoutJob?.cancel()
            pendingTimeoutJob = null
        }
        currentRunState = newState
        _runState.value = newState
    }

    private fun startPendingTimeout() {
        pendingTimeoutJob?.cancel()
        pendingTimeoutJob = scope.launch {
            delay(PENDING_TIMEOUT_MS)
            if (currentRunState == RunState.PENDING) {
                android.util.Log.w("GlobalState", "PENDING state timeout, resetting to STOP")
                updateRunState(RunState.STOP)
            }
        }
    }

    fun updateIsStopping(value: Boolean) {
        isStopping = value
        runCatching {
            val ts = if (value) System.currentTimeMillis() else 0L
            BettboxApplication.getAppContext()
                .getSharedPreferences("vpn_state", android.content.Context.MODE_PRIVATE)
                .edit()
                .putLong("stop_lock_ts", ts)
                .apply()
        }
    }

    fun isCurrentlyStopping(): Boolean {
        if (isStopping) return true
        return runCatching {
            val sp = BettboxApplication.getAppContext()
                .getSharedPreferences("vpn_state", android.content.Context.MODE_PRIVATE)
            val ts = sp.getLong("stop_lock_ts", 0L)
            if (ts == 0L) return false

            val now = System.currentTimeMillis()
            if (now - ts > STOP_LOCK_TIMEOUT_MS) {
                sp.edit().remove("stop_lock_ts").apply()
                false
            } else {
                true
            }
        }.getOrDefault(false)
    }

    fun getCurrentAppPlugin(): AppPlugin? {
        val currentEngine = flutterEngine ?: serviceEngine
        return currentEngine?.plugins?.get(AppPlugin::class.java) as? AppPlugin
    }

    fun syncStatus() {
        if (currentRunState == RunState.PENDING) return
        val status = VpnPlugin.getStatus()
        updateRunState(if (status) RunState.START else RunState.STOP)
    }

    suspend fun getText(text: String): String = getCurrentAppPlugin()?.getText(text) ?: ""

    fun getCurrentTilePlugin(): TilePlugin? {
        val currentEngine = flutterEngine ?: serviceEngine
        return currentEngine?.plugins?.get(TilePlugin::class.java) as? TilePlugin
    }

    fun getCurrentVPNPlugin(): VpnPlugin? {
        return serviceEngine?.plugins?.get(VpnPlugin::class.java) as? VpnPlugin
    }

    fun handleToggle() {
        if (!acquireToggleSlot()) return
        if (!handleStart(skipDebounce = true)) {
            handleStop(skipDebounce = true)
        }
    }

    fun handleStart(skipDebounce: Boolean = false): Boolean {
        if (!skipDebounce && !acquireToggleSlot()) return false
        if (currentRunState != RunState.STOP) return false

        updateRunState(RunState.PENDING)
        startPendingTimeout()
        runLock.withLock {
            getCurrentTilePlugin()?.handleStart() ?: initServiceEngine()
        }
        return true
    }

    fun handleStop(skipDebounce: Boolean = false) {
        if (!skipDebounce && !acquireToggleSlot()) return
        if (currentRunState != RunState.START) return

        updateRunState(RunState.PENDING)
        startPendingTimeout()
        runLock.withLock {
            getCurrentTilePlugin()?.handleStop()
        }
    }

    private fun acquireToggleSlot(): Boolean {
        val now = SystemClock.elapsedRealtime()
        synchronized(this) {
            if (now - lastToggleAt < TOGGLE_DEBOUNCE_MS) return false
            lastToggleAt = now
            return true
        }
    }

    fun handleTryDestroy() {
        if (flutterEngine == null) destroyServiceEngine()
    }

    fun destroyServiceEngine() {
        runLock.withLock {
            serviceEngine?.destroy()
            serviceEngine = null
        }
    }

    fun initServiceEngine(flags: List<String>? = null) {
        runLock.withLock {
            if (serviceEngine != null) return
            
            val defaultArgs = if (flutterEngine == null && !isCurrentlyStopping()) listOf("quick") else null
            val args = flags ?: defaultArgs
            
            val app = BettboxApplication.getAppContext() as BettboxApplication
            val vpnService = DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "_service"
            )
            val options = io.flutter.embedding.engine.FlutterEngineGroup.Options(app).apply {
                dartEntrypoint = vpnService
                dartEntrypointArgs = args
            }
            
            serviceEngine = app.engineGroup.createAndRunEngine(options).apply {
                GeneratedPluginRegistrant.registerWith(this)
                listOf(VpnPlugin, AppPlugin(), TilePlugin(), ServicePlugin()).forEach { plugin ->
                    if (plugins.get(plugin.javaClass) == null) {
                        plugins.add(plugin)
                    }
                }
            }
        }
    }

    fun isServiceEngineRunning(): Boolean = serviceEngine != null

    fun reconnectIpc() {
        (serviceEngine?.plugins?.get(TilePlugin::class.java) as? TilePlugin)?.handleReconnectIpc()
    }
}
