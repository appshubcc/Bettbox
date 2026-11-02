package com.appshub.bettbox.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.text.StaticLayout
import android.text.TextPaint
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import com.appshub.bettbox.R
import com.appshub.bettbox.RunState
import com.appshub.bettbox.extensions.getActionIntent
import org.json.JSONObject
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

class HomeWidgetRenderer(
    private val context: Context,
    private val data: JSONObject?,
    private val runState: RunState,
) {
    private val metrics = context.resources.displayMetrics
    private val density = metrics.density
    private val night =
        context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK ==
            Configuration.UI_MODE_NIGHT_YES
    private val light = data?.optJSONObject("light")
    private val dark = data?.optJSONObject("dark")

    private fun color(set: JSONObject?, key: String, fallback: Long): Int =
        (set?.optLong(key, fallback) ?: fallback).toInt()

    private fun colors(key: String): Pair<Int, Int> = when (key) {
        "surface" -> color(light, key, 0xFFEEF4F2) to color(dark, key, 0xFF1B2120)
        "tonal" -> color(light, key, 0xFFDDE4E2) to color(dark, key, 0xFF303634)
        "onSurface" -> color(light, key, 0xFF171D1C) to color(dark, key, 0xFFDDE4E2)
        "onSurfaceVariant" -> color(light, key, 0xFF3F4947) to color(dark, key, 0xFFBEC9C6)
        "primary" -> color(light, key, 0xFF006A60) to color(dark, key, 0xFF82D5C8)
        "active" -> color(light, key, 0xFF9EF2E4) to color(dark, key, 0xFF82D5C8)
        "onActive" -> color(light, key, 0xFF00201C) to color(dark, key, 0xFF003731)
        else -> color(light, key, 0xFFFFFFFF) to color(dark, key, 0xFF003731)
    }

    private fun apply(views: RemoteViews, id: Int, method: String, key: String) {
        val (day, nightColor) = colors(key)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorInt(id, method, day, nightColor)
        } else {
            views.setInt(id, method, if (night) nightColor else day)
        }
    }

    private fun tint(views: RemoteViews, id: Int, key: String) =
        apply(views, id, "setColorFilter", key)

    private fun text(views: RemoteViews, id: Int, key: String) =
        apply(views, id, "setTextColor", key)

    private fun string(key: String): String = data?.optString(key, "") ?: ""

    private fun show(views: RemoteViews, id: Int, visible: Boolean) =
        views.setViewVisibility(id, if (visible) View.VISIBLE else View.GONE)

    private fun activity(code: Int, intent: Intent?): PendingIntent? = intent?.let {
        PendingIntent.getActivity(
            context,
            code,
            it,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun tempActivity(action: String): Intent =
        context.getActionIntent(action).addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)

    fun build(style: HomeWidgetStyle, options: Bundle): RemoteViews {
        val layout = when (style) {
            HomeWidgetStyle.LARGE -> R.layout.home_widget_large
            HomeWidgetStyle.WIDE -> R.layout.home_widget_wide
            HomeWidgetStyle.SQUARE -> R.layout.home_widget_square
        }
        val views = RemoteViews(context.packageName, layout)
        tint(views, R.id.hw_bg, "surface")
        activity(10, HomeWidgets.launchIntent(context, null))?.let {
            views.setOnClickPendingIntent(R.id.hw_root, it)
        }
        if (data == null || !data.optBoolean("hasProfile")) {
            show(views, R.id.hw_content, false)
            show(views, R.id.hw_empty, true)
            val empty = string("emptyText")
            views.setTextViewText(
                R.id.hw_empty,
                empty.ifEmpty { context.getString(R.string.home_widget_empty) },
            )
            text(views, R.id.hw_empty, "onSurfaceVariant")
            return views
        }
        show(views, R.id.hw_empty, false)
        show(views, R.id.hw_content, true)
        bindHeader(views, style)
        if (style != HomeWidgetStyle.SQUARE) bindToggle(views, style)
        bindRefresh(views, style)
        bindNode(views, style)
        when (style) {
            HomeWidgetStyle.LARGE -> bindLarge(views, options)
            HomeWidgetStyle.WIDE -> bindWide(views, options)
            HomeWidgetStyle.SQUARE -> bindSquare(views, options)
        }
        return views
    }

    private fun bindHeader(views: RemoteViews, style: HomeWidgetStyle) {
        views.setTextViewText(R.id.hw_name, string("name"))
        text(views, R.id.hw_name, "onSurface")
        if (style == HomeWidgetStyle.LARGE) {
            views.setTextViewText(R.id.hw_updated, string("updated"))
            text(views, R.id.hw_updated, "onSurfaceVariant")
            return
        }
        views.setTextViewText(R.id.hw_subtitle, string("subtitle"))
        if (data?.optBoolean("expired") == true) {
            views.setTextColor(R.id.hw_subtitle, EXPIRED_COLOR)
        } else {
            text(views, R.id.hw_subtitle, "onSurfaceVariant")
        }
    }

    private fun bindToggle(views: RemoteViews, style: HomeWidgetStyle) {
        val on = runState == RunState.START
        tint(views, R.id.hw_toggle_bg, if (on) "active" else "tonal")
        tint(views, R.id.hw_toggle_icon, if (on) "onActive" else "onSurfaceVariant")
        if (style == HomeWidgetStyle.LARGE) {
            views.setTextViewText(
                R.id.hw_toggle_label,
                string(if (on) "onLabel" else "offLabel"),
            )
            text(views, R.id.hw_toggle_label, if (on) "onActive" else "onSurfaceVariant")
        }
        if (runState == RunState.PENDING) {
            views.setInt(R.id.hw_toggle_icon, "setImageAlpha", 110)
            return
        }
        views.setInt(R.id.hw_toggle_icon, "setImageAlpha", 255)
        activity(12, tempActivity("CHANGE"))?.let {
            views.setOnClickPendingIntent(R.id.hw_toggle, it)
        }
    }

    private fun bindRefresh(views: RemoteViews, style: HomeWidgetStyle) {
        val canRefresh = data?.optBoolean("canRefresh") == true
        show(views, R.id.hw_refresh, canRefresh)
        if (!canRefresh) return
        if (style == HomeWidgetStyle.SQUARE) tint(views, R.id.hw_refresh_bg, "tonal")
        val refreshing = data?.optBoolean("refreshing") == true
        show(views, R.id.hw_refresh_icon, !refreshing)
        show(views, R.id.hw_refresh_progress, refreshing)
        tint(views, R.id.hw_refresh_icon, "onSurfaceVariant")
        if (refreshing) return
        activity(13, tempActivity(REFRESH_ACTION))?.let {
            views.setOnClickPendingIntent(R.id.hw_refresh, it)
        }
    }

    private fun bindNode(views: RemoteViews, style: HomeWidgetStyle) {
        val node = string("node")
        views.setTextViewText(R.id.hw_node, node)
        text(views, R.id.hw_node, if (style == HomeWidgetStyle.WIDE) "onSurfaceVariant" else "onSurface")
        val delay = string("delay")
        show(views, R.id.hw_delay, delay.isNotEmpty())
        views.setTextViewText(R.id.hw_delay, delay)
        val delayColor = data?.optLong("delayColor", 0L) ?: 0L
        if (delayColor != 0L) {
            views.setTextColor(R.id.hw_delay, delayColor.toInt())
        } else {
            text(views, R.id.hw_delay, "onSurfaceVariant")
        }
    }

    private fun bindLarge(views: RemoteViews, options: Bundle) {
        views.setTextViewText(R.id.hw_used, string("used"))
        text(views, R.id.hw_used, "onSurface")
        views.setTextViewText(R.id.hw_total, string("total"))
        text(views, R.id.hw_total, "onSurfaceVariant")
        views.setTextViewText(R.id.hw_percent, string("percent"))
        text(views, R.id.hw_percent, "primary")
        val width = widthDp(options, 250f) - 26f
        views.setImageViewBitmap(R.id.hw_bar, bar(segments(), width, 5f))
        tint(views, R.id.hw_bar, "primary")
        val showStats = largeFits(heightDp(options, 180f))
        show(views, R.id.hw_stats, showStats)
        if (showStats) {
            views.setTextViewText(R.id.hw_first_label, string("firstLabel"))
            views.setTextViewText(R.id.hw_first_value, string("firstValue"))
            views.setTextViewText(R.id.hw_second_label, string("secondLabel"))
            views.setTextViewText(R.id.hw_second_value, string("secondValue"))
            listOf(R.id.hw_first_label, R.id.hw_second_label).forEach {
                text(views, it, "onSurfaceVariant")
            }
            text(views, R.id.hw_first_value, "onSurface")
            if (data?.optBoolean("expired") == true) {
                views.setTextColor(R.id.hw_second_value, EXPIRED_COLOR)
            } else {
                text(views, R.id.hw_second_value, "onSurface")
            }
            tint(views, R.id.hw_first_bg, "tonal")
            tint(views, R.id.hw_second_bg, "tonal")
        }
        views.setTextViewText(R.id.hw_node_label, string("nodeLabel"))
        text(views, R.id.hw_node_label, "onSurfaceVariant")
        tint(views, R.id.hw_node_chevron, "onSurfaceVariant")
        tint(views, R.id.hw_node_bg, "tonal")
    }

    private fun bindWide(views: RemoteViews, options: Bundle) {
        views.setTextViewText(R.id.hw_usage, string("usage"))
        text(views, R.id.hw_usage, "onSurface")
        val width = widthDp(options, 250f) - 24f - 54f
        views.setImageViewBitmap(R.id.hw_bar, bar(segments(), width, 4f))
        tint(views, R.id.hw_bar, "primary")
    }

    private fun bindSquare(views: RemoteViews, options: Bundle) {
        views.setTextViewText(R.id.hw_percent, string("percent").ifEmpty { "—" })
        text(views, R.id.hw_percent, "onSurface")
        views.setTextViewText(R.id.hw_used, string("used"))
        text(views, R.id.hw_used, "onSurface")
        views.setTextViewText(R.id.hw_total, string("total"))
        text(views, R.id.hw_total, "onSurfaceVariant")
        views.setImageViewBitmap(R.id.hw_ring, ring(segments(), RING_SIZE))
        tint(views, R.id.hw_ring, "primary")
        val expire = string("expireShort")
        val (showExpire, showInfo) = squareFits(heightDp(options, 170f), expire.isNotEmpty())
        show(views, R.id.hw_info, showInfo)
        show(views, R.id.hw_expire_row, showExpire)
        if (!showInfo) return
        tint(views, R.id.hw_info_bg, "tonal")
        views.setTextViewText(R.id.hw_node_label, string("nodeLabel"))
        text(views, R.id.hw_node_label, "onSurfaceVariant")
        if (!showExpire) return
        views.setTextViewText(R.id.hw_expire_label, string("secondLabel"))
        text(views, R.id.hw_expire_label, "onSurfaceVariant")
        views.setTextViewText(R.id.hw_expire, expire)
        if (data?.optBoolean("expired") == true) {
            views.setTextColor(R.id.hw_expire, EXPIRED_COLOR)
        } else {
            text(views, R.id.hw_expire, "onSurface")
        }
    }

    private fun lineDp(key: String, sp: Float, bold: Boolean = false): Float {
        val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            textSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, sp, metrics)
            if (bold) typeface = Typeface.DEFAULT_BOLD
        }
        val value = string(key).ifEmpty { " " }
        val builder = StaticLayout.Builder.obtain(value, 0, value.length, paint, MEASURE_WIDTH)
            .setIncludePad(true)
            .setMaxLines(1)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            builder.setUseLineSpacingFromFallbacks(true)
        }
        return builder.build().height / density
    }

    private fun largeFits(height: Float): Boolean {
        val header = max(36f, lineDp("name", 15f, true) + lineDp("updated", 11f))
        val usage = max(lineDp("used", 22f, true), lineDp("percent", 12f, true))
        val stats = 14f + max(
            lineDp("firstLabel", 11f) + lineDp("firstValue", 13f, true),
            lineDp("secondLabel", 11f) + lineDp("secondValue", 13f, true),
        )
        val node = 16f + maxOf(14f, lineDp("nodeLabel", 11f), lineDp("node", 12f, true), lineDp("delay", 11f))
        return height >= 20f + header + usage + 10f + stats + node + FIT_MARGIN
    }

    private fun squareFits(height: Float, hasExpire: Boolean): Pair<Boolean, Boolean> {
        val base = 20f + max(36f, lineDp("name", 13f, true) + lineDp("subtitle", 11f)) + RING_SIZE
        val info = 16f + maxOf(lineDp("nodeLabel", 11f), lineDp("node", 11f, true), lineDp("delay", 11f))
        val expire = 2f + max(lineDp("secondLabel", 11f), lineDp("expireShort", 11f, true))
        return when {
            hasExpire && height >= base + info + expire + FIT_MARGIN -> true to true
            height >= base + info + FIT_MARGIN -> false to true
            else -> false to false
        }
    }

    private fun segments(): List<Float> {
        val array = data?.optJSONArray("segments") ?: return listOf(0f)
        val values = (0 until array.length()).map { array.optDouble(it, 0.0).toFloat().coerceIn(0f, 1f) }
        return values.ifEmpty { listOf(0f) }
    }

    private fun widthDp(options: Bundle, fallback: Float): Float {
        val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        return if (width > 0) width.toFloat() else fallback
    }

    private fun heightDp(options: Bundle, fallback: Float): Float {
        val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0)
        return if (height > 0) height.toFloat() else fallback
    }

    private fun maskPaint(alpha: Int) = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0xFFFFFFFF.toInt()
        this.alpha = alpha
    }

    private fun bar(values: List<Float>, widthDp: Float, heightDp: Float): Bitmap {
        val width = min(max((widthDp * density).roundToInt(), 1), MAX_BITMAP_WIDTH)
        val height = max((heightDp * density).roundToInt(), 1)
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ALPHA_8)
        val canvas = Canvas(bitmap)
        val gap = if (values.size > 1) 3 * density else 0f
        val segment = (width - gap * (values.size - 1)) / values.size
        val radius = height / 2f
        val track = maskPaint(TRACK_ALPHA)
        val fill = maskPaint(255)
        values.forEachIndexed { index, value ->
            val left = index * (segment + gap)
            canvas.drawRoundRect(RectF(left, 0f, left + segment, height.toFloat()), radius, radius, track)
            if (value > 0f) {
                val right = left + max(segment * value, height.toFloat())
                canvas.drawRoundRect(RectF(left, 0f, min(right, left + segment), height.toFloat()), radius, radius, fill)
            }
        }
        return bitmap
    }

    private fun ring(values: List<Float>, sizeDp: Float): Bitmap {
        val size = max((sizeDp * density).roundToInt(), 1)
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ALPHA_8)
        val canvas = Canvas(bitmap)
        val stroke = 6 * density
        val rect = RectF(stroke / 2, stroke / 2, size - stroke / 2, size - stroke / 2)
        val multi = values.size > 1
        fun paint(alpha: Int) = maskPaint(alpha).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = if (multi) Paint.Cap.BUTT else Paint.Cap.ROUND
        }
        val track = paint(TRACK_ALPHA)
        val fill = paint(255)
        val gap = if (multi) 8f else 0f
        val sweep = (360f - gap * values.size) / values.size
        var start = -90f + gap / 2
        values.forEach { value ->
            canvas.drawArc(rect, start, sweep, false, track)
            if (value > 0f) canvas.drawArc(rect, start, sweep * value, false, fill)
            start += sweep + gap
        }
        return bitmap
    }

    companion object {
        const val REFRESH_ACTION = "WIDGET_REFRESH"
        private const val TRACK_ALPHA = 40
        private const val MAX_BITMAP_WIDTH = 1600
        private const val MEASURE_WIDTH = 4096
        private const val RING_SIZE = 58f
        private const val FIT_MARGIN = 2f
        private const val EXPIRED_COLOR = 0xFFE5484D.toInt()
    }
}
