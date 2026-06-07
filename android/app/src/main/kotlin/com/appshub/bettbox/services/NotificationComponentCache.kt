package com.appshub.bettbox.services

import android.content.ComponentName
import android.content.pm.PackageManager

object NotificationComponentCache {

    @Volatile
    private var cached: ComponentName? = null

    fun get(
        packageManager: PackageManager,
        defaultComponent: ComponentName,
        lightComponent: ComponentName,
    ): ComponentName {
        cached?.let { return it }

        synchronized(this) {
            cached?.let { return it }
            val result = resolve(packageManager, defaultComponent, lightComponent)
            cached = result
            return result
        }
    }

    fun invalidate() {
        cached = null
    }

    private fun resolve(
        packageManager: PackageManager,
        defaultComponent: ComponentName,
        lightComponent: ComponentName,
    ): ComponentName {
        val defaultState = runCatching {
            packageManager.getComponentEnabledSetting(defaultComponent)
        }.getOrDefault(PackageManager.COMPONENT_ENABLED_STATE_DEFAULT)

        val lightState = runCatching {
            packageManager.getComponentEnabledSetting(lightComponent)
        }.getOrDefault(PackageManager.COMPONENT_ENABLED_STATE_DEFAULT)

        return when {
            lightState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> lightComponent
            lightState == PackageManager.COMPONENT_ENABLED_STATE_DISABLED -> defaultComponent
            defaultState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> defaultComponent
            defaultState == PackageManager.COMPONENT_ENABLED_STATE_DISABLED -> lightComponent
            else -> runCatching {
                packageManager.getActivityInfo(lightComponent, 0)
                    .takeIf { it.enabled }?.let { lightComponent }
            }.getOrNull() ?: defaultComponent
        }
    }
}
