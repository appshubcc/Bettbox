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

        private fun notify(method: String, arguments: Any? = null) {
            mainHandler.post {
                activeChannels.forEach { ch ->
                    runCatching { ch.invokeMethod(method, arguments) }
                        .onFailure { Log.e(TAG, "$method notify error: ${it.message}") }
                }
            }
        }

        fun notifyNetworkChanged() = notify("networkChanged")
        fun notifyVpnStartFailed() = notify("vpnStartFailed")
        fun notifyScreenStateChanged(isOn: Boolean) = notify("screenStateChanged", isOn)
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
            "resumeCore" -> {
                Thread {
                    VpnPlugin.resumeCore()
                    mainHandler.post { result.success(true) }
                }.start()
            }
            "isSmartStopped" -> result.success(GlobalState.isSmartStopped)
            "requestSmartAutoStopCheck" -> {
                VpnPlugin.requestSmartAutoStopCheck()
                result.success(true)
            }
            "getLocalIpAddresses" -> result.success(VpnPlugin.getLocalIpAddresses())
            "getLocalGateways" -> result.success(VpnPlugin.getLocalGateways())
            "getNetworkInfo" -> result.success(VpnPlugin.getNetworkInfo())
            "getCurrentDns" -> result.success(VpnPlugin.getCurrentDns())
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
                GlobalState.isSpeedNotificationEnabled = false
                VpnPlugin.restoreNotification()
                result.success(true)
            }
            "setHighPriorityNotification" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                VpnPlugin.setHighPriorityNotification(enabled)
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
