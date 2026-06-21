package com.appshub.bettbox

import android.app.UiModeManager
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.appshub.bettbox.plugins.AppPlugin
import com.appshub.bettbox.plugins.ServicePlugin
import com.appshub.bettbox.plugins.TilePlugin
import com.appshub.bettbox.plugins.VpnPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
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

    private fun createAndCacheEngine(context: Context, cache: FlutterEngineCache) =
        FlutterEngine(context.applicationContext).apply {
            GeneratedPluginRegistrant.registerWith(this)
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
            cache.put(MAIN_ENGINE_ID, this)
            GlobalState.flutterEngine = this
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        listOf(VpnPlugin, AppPlugin(), ServicePlugin(), TilePlugin()).forEach { plugin ->
            if (flutterEngine.plugins.get(plugin.javaClass) == null) {
                flutterEngine.plugins.add(plugin)
            }
        }

        GlobalState.flutterEngine = flutterEngine
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun onDestroy() {
        super.onDestroy()
        if (GlobalState.currentRunState != RunState.STOP) {
            val engineCache = FlutterEngineCache.getInstance()
            engineCache.get(MAIN_ENGINE_ID)?.let { engine ->
                engine.destroy()
                engineCache.remove(MAIN_ENGINE_ID)
            }
            GlobalState.flutterEngine = null
        }
    }
}