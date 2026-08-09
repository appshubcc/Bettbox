package com.appshub.bettbox

import android.app.UiModeManager
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.appshub.bettbox.plugins.AppPlugin
import com.appshub.bettbox.plugins.ServicePlugin
import com.appshub.bettbox.plugins.TilePlugin
import com.appshub.bettbox.plugins.VpnPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object {
        private const val MAIN_ENGINE_ID = "bettbox_main_engine"
    }

    private fun isTvDevice(context: Context): Boolean {
        val uiModeManager = context.getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
        if (uiModeManager?.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION) {
            return true
        }
        val packageManager = context.packageManager
        return packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
                || packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val isEngineCached = FlutterEngineCache.getInstance().contains(MAIN_ENGINE_ID)
        if (isTvDevice(this) || isEngineCached) {
            setTheme(R.style.NormalTheme)
        } else {
            installSplashScreen()
        }
        super.onCreate(savedInstanceState)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val engineCache = FlutterEngineCache.getInstance()
        return engineCache.get(MAIN_ENGINE_ID) ?: createAndCacheEngine(context, engineCache)
    }

    private fun createAndCacheEngine(context: Context, cache: FlutterEngineCache): FlutterEngine {
        val app = context.applicationContext as BettboxApplication
        val options = FlutterEngineGroup.Options(app).apply {
            dartEntrypoint = DartExecutor.DartEntrypoint.createDefault()
        }
        return app.engineGroup.createAndRunEngine(options).apply {
            GeneratedPluginRegistrant.registerWith(this)
            cache.put(MAIN_ENGINE_ID, this)
            GlobalState.flutterEngine = this
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        listOf(VpnPlugin, AppPlugin(), ServicePlugin(), TilePlugin()).forEach { plugin ->
            if (flutterEngine.plugins.get(plugin.javaClass) == null) {
                flutterEngine.plugins.add(plugin)
            }
        }

        setupHapticsChannel(flutterEngine)

        GlobalState.flutterEngine = flutterEngine
    }

    private fun setupHapticsChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "code_forge/haptics")
            .setMethodCallHandler { call, result ->
                val decorView = window?.decorView
                if (decorView == null) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "handleMove" -> {
                        decorView.performHapticFeedback(
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                HapticFeedbackConstants.TEXT_HANDLE_MOVE
                            } else {
                                HapticFeedbackConstants.LONG_PRESS
                            }
                        )
                        result.success(null)
                    }
                    "longPress" -> {
                        decorView.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        val engine = flutterEngine
        if (engine != null) {
            engine.navigationChannel.popRoute()
        } else {
            super.onBackPressed()
        }
    }

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        return try {
            super.dispatchTouchEvent(ev)
        } catch (e: RuntimeException) {
            if (e.message?.contains("FlutterJNI is not attached to native") == true) {
                Log.w("MainActivity", "Ignore touch event while FlutterJNI is not attached")
                false
            } else {
                throw e
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
