package com.appshub.bettbox.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.plugins.AppPlugin
import org.json.JSONObject

enum class HomeWidgetStyle { LARGE, WIDE, SQUARE }

abstract class HomeWidgetProvider : AppWidgetProvider() {
    abstract val style: HomeWidgetStyle

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val snapshot = HomeWidgets.snapshot(context)
        ids.forEach { HomeWidgets.render(context, manager, it, style, snapshot) }
        if (snapshot == null) HomeWidgets.notifyDart("homeWidgetsChanged", true)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        options: Bundle,
    ) {
        HomeWidgets.render(context, manager, id, style, HomeWidgets.snapshot(context))
    }

    override fun onEnabled(context: Context) {
        HomeWidgets.notifyDart("homeWidgetsChanged", true)
    }

    override fun onDisabled(context: Context) {
        HomeWidgets.notifyDart("homeWidgetsChanged", HomeWidgets.hasWidgets(context))
    }
}

class HomeWidgetLargeProvider : HomeWidgetProvider() {
    override val style = HomeWidgetStyle.LARGE
}

class HomeWidgetWideProvider : HomeWidgetProvider() {
    override val style = HomeWidgetStyle.WIDE
}

class HomeWidgetSquareProvider : HomeWidgetProvider() {
    override val style = HomeWidgetStyle.SQUARE
}

object HomeWidgets {
    private const val PREFS = "home_widget"
    private const val KEY_SNAPSHOT = "snapshot"
    const val EXTRA_ACTION = "bettbox.home_widget.action"
    const val ACTION_REFRESH = "refresh"

    @Volatile
    private var pendingAction: String? = null

    private val providers = listOf(
        HomeWidgetLargeProvider::class.java to HomeWidgetStyle.LARGE,
        HomeWidgetWideProvider::class.java to HomeWidgetStyle.WIDE,
        HomeWidgetSquareProvider::class.java to HomeWidgetStyle.SQUARE,
    )

    private fun ids(context: Context, manager: AppWidgetManager, provider: Class<*>): IntArray =
        runCatching { manager.getAppWidgetIds(ComponentName(context, provider)) }
            .getOrDefault(IntArray(0))

    fun hasWidgets(context: Context): Boolean {
        val manager = AppWidgetManager.getInstance(context)
        return providers.any { ids(context, manager, it.first).isNotEmpty() }
    }

    fun snapshot(context: Context): JSONObject? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_SNAPSHOT, null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }

    fun save(context: Context, data: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_SNAPSHOT, data)
            .apply()
        refreshAll(context)
    }

    fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        var snapshot: JSONObject? = null
        var loaded = false
        for ((provider, style) in providers) {
            val ids = ids(context, manager, provider)
            if (ids.isEmpty()) continue
            if (!loaded) {
                snapshot = snapshot(context)
                loaded = true
            }
            ids.forEach { render(context, manager, it, style, snapshot) }
        }
    }

    fun render(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        style: HomeWidgetStyle,
        snapshot: JSONObject?,
    ) {
        runCatching {
            val views = HomeWidgetRenderer(context, snapshot, GlobalState.currentRunState)
                .build(style, manager.getAppWidgetOptions(id))
            manager.updateAppWidget(id, views)
        }
    }

    fun launchIntent(context: Context, action: String?): Intent? =
        context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP,
            )
            if (action != null) putExtra(EXTRA_ACTION, action)
        }

    fun notifyDart(method: String, argument: Any): Boolean {
        val plugin = GlobalState.flutterEngine?.plugins?.get(AppPlugin::class.java) as? AppPlugin
            ?: return false
        return plugin.invokeHomeWidget(method, argument)
    }

    fun dispatch(action: String) {
        if (notifyDart("homeWidgetAction", action)) return
        pendingAction = action
    }

    fun handleIntent(intent: Intent?) {
        val action = intent?.getStringExtra(EXTRA_ACTION) ?: return
        intent.removeExtra(EXTRA_ACTION)
        dispatch(action)
    }

    fun refresh(context: Context) {
        if (notifyDart("homeWidgetAction", ACTION_REFRESH)) return
        launchIntent(context, ACTION_REFRESH)?.let { context.startActivity(it) }
    }

    fun consumePendingAction(): String? {
        val action = pendingAction
        pendingAction = null
        return action
    }
}
