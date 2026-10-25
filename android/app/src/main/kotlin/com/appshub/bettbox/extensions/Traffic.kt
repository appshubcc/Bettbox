package com.appshub.bettbox.extensions

import org.json.JSONObject
import java.math.BigDecimal
import java.math.RoundingMode

private val trafficUnits = listOf(
    1099511627776L to "TB",
    1073741824L to "GB",
    1048576L to "MB",
    1024L to "KB",
)

fun formatTrafficValue(value: Long): String {
    val unit = trafficUnits.firstOrNull { value > it.first }
    val scaled = unit?.let { value / it.first.toDouble() } ?: value.toDouble()
    return BigDecimal(scaled).setScale(2, RoundingMode.HALF_UP).toPlainString() + (unit?.second ?: "B")
}

fun trafficSpeedInfo(json: String): String? = runCatching {
    val traffic = JSONObject(json)
    "${formatTrafficValue(traffic.optLong("up"))}↑ ${formatTrafficValue(traffic.optLong("down"))}↓"
}.getOrNull()
