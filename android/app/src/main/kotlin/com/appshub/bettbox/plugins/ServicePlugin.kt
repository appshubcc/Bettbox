package com.appshub.bettbox.plugins

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.RunState
import com.appshub.bettbox.models.VpnOptions
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CopyOnWriteArrayList

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    companion object {
        private val activeChannels = CopyOnWriteArrayList<MethodChannel>()
        private val mainHandler = Handler(Looper.getMainLooper())
        private val gson = Gson()
        private const val TAG = "ServicePlugin"

        private fun notify(method: String) {
            mainHandler.post {
                activeChannels.forEach { ch ->
                    runCatching { ch.invokeMethod(method, null) }
                        .onFailure { Log.e(TAG, "$method notify error: ${it.message}") }
                }
            }
        }

        fun notifyNetworkChanged() = notify("networkChanged")
        fun notifyQuickResponse() = notify("quickResponse")
        fun notifyVpnStartFailed() = notify("vpnStartFailed")
        fun notifyRunStateChanged(state: RunState) {
            mainHandler.post {
                activeChannels.forEach { ch ->
                    runCatching { ch.invokeMethod("runStateChanged", state.name) }
                        .onFailure { Log.e(TAG, "runStateChanged notify error: ${it.message}") }
                }
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "service").apply {
            setMethodCallHandler(this@ServicePlugin)
        }
        activeChannels.add(channel)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        activeChannels.remove(channel)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startVpn" -> handleStartVpn(call, result)
            "stopVpn" -> {
                VpnPlugin.handleStop(force = true)
                result.success(true)
            }
            "smartStop" -> {
                VpnPlugin.handleSmartStop()
                result.success(true)
            }
            "smartResume" -> {
                val data = call.argument<String>("data")
                val options = gson.fromJson(data, VpnOptions::class.java)
                VpnPlugin.handleSmartResume(options)
                result.success(true)
            }
            "setSmartStopped" -> {
                GlobalState.isSmartStopped = call.argument<Boolean>("value") ?: false
                result.success(true)
            }
            "isSmartStopped" -> result.success(GlobalState.isSmartStopped)
            "getLocalIpAddresses" -> result.success(VpnPlugin.getLocalIpAddresses())
            "getLocalGateways" -> result.success(VpnPlugin.getLocalGateways())
            "setQuickResponse" -> {
                VpnPlugin.setQuickResponse(call.argument<Boolean>("enabled") ?: false)
                result.success(true)
            }
            "init" -> {
                GlobalState.getCurrentAppPlugin()?.requestNotificationsPermission()
                GlobalState.initServiceEngine()
                result.success(true)
            }
            "isServiceEngineRunning" -> result.success(GlobalState.isServiceEngineRunning())
            "status" -> result.success(GlobalState.currentRunState == RunState.START)
            "reconnectIpc" -> {
                GlobalState.reconnectIpc()
                result.success(true)
            }
            "destroy" -> {
                GlobalState.destroyServiceEngine()
                result.success(true)
            }
            "updateNotificationSpeed" -> {
                VpnPlugin.handleUpdateNotificationSpeed(
                    call.argument<String>("profileName") ?: "",
                    call.argument<String>("speedInfo") ?: ""
                )
                result.success(true)
            }
            "restoreNotification" -> {
                val context = com.appshub.bettbox.BettboxApplication.getAppContext()
                if (context != null) {
                    com.appshub.bettbox.GlobalState.isSpeedNotificationEnabled = false
                    android.service.quicksettings.TileService.requestListeningState(
                        context,
                        android.content.ComponentName(context, com.appshub.bettbox.services.BettboxTileService::class.java)
                    )

                    val intent = android.content.Intent(
                        context, 
                        com.appshub.bettbox.services.BettboxVpnService::class.java
                    ).apply {
                        action = "RESTORE_NOTIFICATION"
                    }
                    runCatching { context.startService(intent) }
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleStartVpn(call: MethodCall, result: MethodChannel.Result) {
        val data = call.argument<String>("data")
        if (data.isNullOrBlank() || data == "null") {
            result.error("INVALID_ARGUMENT", "options data is null", null)
            return
        }
        runCatching { gson.fromJson(data, VpnOptions::class.java) }
            .onSuccess { options ->
                VpnPlugin.handleStart(options)
                result.success(true)
            }
            .onFailure { result.error("PARSE_ERROR", it.message, null) }
    }
}
