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
        darkComponent: ComponentName,
    ): ComponentName {
        cached?.let { return it }

        synchronized(this) {
            cached?.let { return it }
            val result = resolve(packageManager, defaultComponent, lightComponent, darkComponent)
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
        darkComponent: ComponentName,
    ): ComponentName {
        val darkState = runCatching {
            packageManager.getComponentEnabledSetting(darkComponent)
        }.getOrDefault(PackageManager.COMPONENT_ENABLED_STATE_DEFAULT)

        val lightState = runCatching {
            packageManager.getComponentEnabledSetting(lightComponent)
        }.getOrDefault(PackageManager.COMPONENT_ENABLED_STATE_DEFAULT)

        return when {
            darkState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> darkComponent
            lightState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> lightComponent
            else -> defaultComponent
        }
    }
}
