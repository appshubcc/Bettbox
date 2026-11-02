package com.appshub.bettbox.core

import android.util.Log
import java.net.InetSocketAddress

object Core {

    private external fun startTun(fd: Int, cb: TunInterface): Boolean
    private external fun suspend(suspended: Int)
    private external fun setScreenState(on: Int)
    private external fun networkChanged()
    private external fun getTraffic(): String
    private external fun purgeMemory(all: Boolean)
    external fun stopTun()

    init {
        System.loadLibrary("core")
    }

    private fun parseInetSocketAddress(address: String): InetSocketAddress {
        val lastColonIndex = address.lastIndexOf(':')
        if (lastColonIndex == -1) {
            return InetSocketAddress(address, 0)
        }

        val host = address.substring(0, lastColonIndex).removeSurrounding("[", "]")
        val port = address.substring(lastColonIndex + 1).toIntOrNull() ?: 0

        return InetSocketAddress(host, port)
    }

    fun startTun(
        fd: Int,
        protect: (Int) -> Boolean,
        resolverProcess: (protocol: Int, source: InetSocketAddress, target: InetSocketAddress, uid: Int) -> String
    ): Boolean {
        return startTun(fd, object : TunInterface {
            override fun protect(fd: Int) {
                runCatching { protect(fd) }
                    .onFailure { Log.e("Core", "protect JNI callback error: ${it.message}") }
            }

            override fun resolverProcess(
                protocol: Int,
                source: String,
                target: String,
                uid: Int
            ): String = runCatching {
                resolverProcess(
                    protocol,
                    parseInetSocketAddress(source),
                    parseInetSocketAddress(target),
                    uid
                )
            }.onFailure {
                Log.e("Core", "resolverProcess JNI callback error: ${it.message}")
            }.getOrDefault("")
        })
    }

    fun trafficJson(): String? = runCatching { getTraffic() }.getOrNull()

    fun purge(all: Boolean = false) {
        runCatching {
            purgeMemory(all)
        }.onFailure {
            Log.e("Core", "Error calling purgeMemory: ${it.message}", it)
        }
    }

    fun suspended(value: Boolean) {
        runCatching {
            Log.d("Core", "suspended called with value: $value")
            suspend(if (value) 1 else 0)
            Log.d("Core", "suspend JNI call completed")
        }.onFailure {
            Log.e("Core", "Error calling suspend: ${it.message}", it)
        }
    }

    fun screenStateChanged(isOn: Boolean) {
        runCatching {
            setScreenState(if (isOn) 1 else 0)
        }.onFailure {
            Log.e("Core", "Error calling setScreenState: ${it.message}", it)
        }
    }

    fun onNetworkChanged() {
        runCatching {
            networkChanged()
        }.onFailure {
            Log.e("Core", "Error calling networkChanged: ${it.message}", it)
        }
    }

    fun dozeSuspend(value: Boolean) {
        runCatching {
            Log.d("Core", "dozeSuspend called with value: $value")
            suspend(if (value) 2 else 0)
            Log.d("Core", "dozeSuspend JNI call completed")
        }.onFailure {
            Log.e("Core", "Error calling dozeSuspend: ${it.message}", it)
        }
    }
}
