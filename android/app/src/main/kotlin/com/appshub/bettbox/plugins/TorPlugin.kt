package com.appshub.bettbox.plugins

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.net.URI
import java.net.InetSocketAddress
import java.net.Socket
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import org.json.JSONObject

data class TorStartOptions(
    val enabled: Boolean = false,
    val bridgeMode: String = "obfs4",
    val customBridgesEnabled: Boolean = false,
    val customBridges: List<String> = emptyList(),
    val upstreamSocksPort: Int = 12334,
    val socksPort: Int = 19050,
    val controlPort: Int = 19051,
    val dnsPort: Int = 19053,
)

class TorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "TorPlugin"

        private val DEFAULT_OBFS4_BRIDGES = listOf(
            "obfs4 192.95.36.142:443 CDF2E852BF539B82BD10E27E9115A31734E378C2 cert=qUVQ0srL1JI/vO6V6m/24anYXiJD3QP2HgzUKQtQ7GRqqUvs7P+tG43RtAqdhLOALP7DJQ iat-mode=1",
            "obfs4 37.218.245.14:38224 D9A82D2F9C2F65A18407B1D2B764F130847F8B5D cert=bjRaMrr1BRiAW8IE9U5z27fQaYgOhX1UCmOpg2pFpoMvo6ZgQMzLsaTzzQNTlm7hNcb+Sg iat-mode=0",
            "obfs4 85.31.186.98:443 011F2599C0E9B27EE74B353155E244813763C3E5 cert=ayq0XzCwhpdysn5o0EyDUbmSOx3X/oTEbzDMvczHOdBJKlvIdHHLJGkZARtT4dcBFArPPg iat-mode=0",
            "obfs4 85.31.186.26:443 91A6354697E6B02A386312F68D82CF86824D3606 cert=PBwr+S8JTVZo6MPdHnkTwXJPILWADLqfMGoVvhZClMq/Urndyd42BwX9YFJHZnBB3H0XCw iat-mode=0",
            "obfs4 144.217.20.138:80 FB70B257C162BF1038CA669D568D76F5B7F0BABB cert=vYIV5MgrghGQvZPIi1tJwnzorMgqgmlKaB77Y3Z9Q/v94wZBOAXkW+fdx4aSxLVnKO+xNw iat-mode=0",
            "obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878FA6060C6BACA cert=4TLQPJrTSaDffMK7Nbao6LC7G9OW/NHkUwIdjLSS3KYf0Nv4/nQiiI8dY2TcsQx01NniOg iat-mode=0",
            "obfs4 209.148.46.65:443 74FAD13168806246602538555B5521A0383A1875 cert=ssH+9rP8dG2NLDN2XuFw63hIO/9MNNinLmxQDpVa+7kTOa9/m+tGWT1SmSYpQ9uTBGa6Hw iat-mode=0",
            "obfs4 146.57.248.225:22 10A6CD36A537FCE513A322361547444B393989F0 cert=K1gDtDAIcUfeLqbstggjIw2rtgIKqdIhUlHp82XRqNSq/mtAjp1BIC9vHKJ2FAEpGssTPw iat-mode=0",
        )
    }

    private var channel: MethodChannel? = null
    private lateinit var appContext: Context
    private var status: String = "disabled"
    private var message: String? = null
    private var lastOptions: TorStartOptions? = null
    private var torProcess: Process? = null
    private var bootstrapPercent: Int = 0
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "tor").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> handleStart(call, result)
            "checkExit" -> handleCheckExit(call, result)
            "traffic" -> handleTraffic(call, result)
            "stop" -> {
                handleStop()
                result.success(true)
            }
            "status" -> result.success(statusMap())
            else -> result.notImplemented()
        }
    }

    private fun handleStart(call: MethodCall, result: MethodChannel.Result) {
        val data = call.argument<String>("data")
        if (data.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "data parameter is required", null)
            return
        }

        val options = runCatching {
            Gson().fromJson(data, TorStartOptions::class.java)
        }.getOrElse {
            result.error("PARSE_ERROR", "Failed to parse Tor options: ${it.message}", null)
            return
        }

        lastOptions = options
        if (!options.enabled) {
            handleStop()
            result.success(statusMap())
            return
        }

        if (options.bridgeMode != "direct" && options.bridgeMode != "obfs4" && !options.customBridgesEnabled) {
            status = "failed"
            message = "Bridge mode ${options.bridgeMode} needs bundled pluggable transports; use direct or custom bridges."
            result.success(statusMap())
            return
        }

        executor.execute {
            val startResult = runCatching {
                startTor(options)
            }
            mainHandler.post {
                startResult
                    .onSuccess { result.success(statusMap()) }
                    .onFailure {
                        status = "failed"
                        message = it.message ?: it.javaClass.simpleName
                        result.success(statusMap())
                    }
            }
        }
    }

    private fun handleCheckExit(call: MethodCall, result: MethodChannel.Result) {
        val socksPort = call.argument<Int>("socksPort") ?: TorStartOptions().socksPort
        executor.execute {
            val checkResult = runCatching {
                checkTorExit(socksPort)
            }
            mainHandler.post {
                checkResult
                    .onSuccess { result.success(it) }
                    .onFailure {
                        result.success(
                            mapOf(
                                "ok" to false,
                                "error" to (it.message ?: it.javaClass.simpleName),
                            )
                        )
                    }
            }
        }
    }

    private fun handleTraffic(call: MethodCall, result: MethodChannel.Result) {
        val controlPort = call.argument<Int>("controlPort") ?: TorStartOptions().controlPort
        executor.execute {
            val trafficResult = runCatching {
                readTraffic(controlPort)
            }
            mainHandler.post {
                trafficResult
                    .onSuccess { result.success(it) }
                    .onFailure {
                        result.success(
                            mapOf(
                                "ok" to false,
                                "up" to 0L,
                                "down" to 0L,
                                "error" to (it.message ?: it.javaClass.simpleName),
                            )
                        )
                    }
            }
        }
    }

    private fun handleStop() {
        torProcess?.destroy()
        if (torProcess?.waitFor(2, TimeUnit.SECONDS) == false) {
            torProcess?.destroyForcibly()
        }
        torProcess = null
        bootstrapPercent = 0
        status = "disabled"
        message = null
        lastOptions = null
    }

    private fun startTor(options: TorStartOptions) {
        handleStop()
        lastOptions = options

        val runtimeDir = ensureTorRuntime()
        val nativeLibDir = File(appContext.applicationInfo.nativeLibraryDir)
        val torBinary = File(nativeLibDir, "libTor.so")
        if (!torBinary.canExecute()) {
            throw IllegalStateException("Tor binary is missing or not executable: ${torBinary.absolutePath}")
        }

        val torDir = File(appContext.filesDir, "tor").also { it.mkdirs() }
        val dataDir = File(torDir, "data").also { it.mkdirs() }
        val torrc = File(torDir, "torrc")
        torrc.writeText(buildTorrc(options, dataDir, runtimeDir))

        status = "starting"
        message = "Starting Tor"
        bootstrapPercent = 0

        torProcess = ProcessBuilder(torBinary.absolutePath, "-f", torrc.absolutePath)
            .directory(torDir)
            .redirectErrorStream(true)
            .apply {
                environment()["HOME"] = torDir.absolutePath
                environment()["TMPDIR"] = appContext.cacheDir.absolutePath
                environment()["TOR_PT_PROXY"] = "socks5://127.0.0.1:${options.upstreamSocksPort}"
            }
            .start()

        watchTorOutput(torProcess!!)
        waitForControlPort(options.controlPort)
        refreshBootstrapStatus(options.controlPort)
    }

    private fun ensureTorRuntime(): File {
        val runtimeDir = File(appContext.filesDir, "tor-runtime-data")
        val marker = File(runtimeDir, ".version-15.0.17")
        if (!marker.exists()) {
            if (runtimeDir.exists()) runtimeDir.deleteRecursively()
            copyAssetTree("tor/aarch64/data", File(runtimeDir, "data"))
            marker.writeText("15.0.17\n")
        }
        return runtimeDir
    }

    private fun copyAssetTree(assetPath: String, destination: File) {
        val children = appContext.assets.list(assetPath).orEmpty()
        if (children.isEmpty()) {
            destination.parentFile?.mkdirs()
            appContext.assets.open(assetPath).use { input ->
                FileOutputStream(destination).use { output ->
                    input.copyTo(output)
                }
            }
            return
        }

        destination.mkdirs()
        children.forEach { child ->
            copyAssetTree("$assetPath/$child", File(destination, child))
        }
    }

    private fun buildTorrc(
        options: TorStartOptions,
        dataDir: File,
        runtimeDir: File,
    ): String {
        val geoip = File(runtimeDir, "data/geoip")
        val geoip6 = File(runtimeDir, "data/geoip6")
        val nativeLibDir = File(appContext.applicationInfo.nativeLibraryDir)
        val lyrebird = File(nativeLibDir, "liblyrebird.so")
        val lines = mutableListOf(
            "DataDirectory ${dataDir.absolutePath}",
            "SocksPort 127.0.0.1:${options.socksPort}",
            "ControlPort 127.0.0.1:${options.controlPort}",
            "DNSPort 127.0.0.1:${options.dnsPort}",
            "CookieAuthentication 0",
            "ClientOnly 1",
            "AvoidDiskWrites 1",
            "SafeLogging 1",
            "GeoIPFile ${geoip.absolutePath}",
            "GeoIPv6File ${geoip6.absolutePath}",
            "Log notice stdout",
        )

        val bridgeLines = effectiveBridges(options)
        if (bridgeLines.isNotEmpty()) {
            lines += "UseBridges 1"
            lines += "ClientTransportPlugin obfs4 exec ${lyrebird.absolutePath}"
            bridgeLines.forEach { lines += "Bridge $it" }
        }

        return lines.joinToString(separator = "\n", postfix = "\n")
    }

    private fun watchTorOutput(process: Process) {
        thread(name = "bettbox-tor-output", isDaemon = true) {
            process.inputStream.bufferedReader().useLines { lines ->
                lines.forEach { line ->
                    Log.i(TAG, line)
                    parseTorLog(line)
                }
            }
            if (torProcess === process && status != "disabled") {
                val exitCode = runCatching { process.exitValue() }.getOrNull()
                status = if (exitCode == 0) "disabled" else "failed"
                message = "Tor process exited${exitCode?.let { " with code $it" } ?: ""}"
            }
        }
    }

    private fun parseTorLog(line: String) {
        val match = Regex("Bootstrapped (\\d+)%").find(line)
        if (match != null) {
            bootstrapPercent = match.groupValues[1].toIntOrNull() ?: bootstrapPercent
            status = if (bootstrapPercent >= 100) "running" else "starting"
            message = line.substringAfter("Bootstrapped", line).trim()
            return
        }
        if (line.contains("[warn]", ignoreCase = true) || line.contains("[err]", ignoreCase = true)) {
            message = line
        }
    }

    private fun waitForControlPort(controlPort: Int) {
        val deadline = System.currentTimeMillis() + 15000
        while (System.currentTimeMillis() < deadline) {
            val process = torProcess
            if (process == null || !process.isAlive) {
                throw IllegalStateException("Tor process exited before control port opened")
            }
            if (canConnect(controlPort)) return
            Thread.sleep(250)
        }
        throw IllegalStateException("Timed out waiting for Tor control port $controlPort")
    }

    private fun canConnect(port: Int): Boolean = runCatching {
        Socket().use { socket ->
            socket.connect(InetSocketAddress("127.0.0.1", port), 300)
        }
    }.isSuccess

    private fun refreshBootstrapStatus(controlPort: Int) {
        Socket().use { socket ->
            socket.connect(InetSocketAddress("127.0.0.1", controlPort), 1000)
            val writer = socket.getOutputStream().bufferedWriter()
            val reader = socket.getInputStream().bufferedReader()
            writer.write("AUTHENTICATE\r\n")
            writer.write("GETINFO status/bootstrap-phase\r\n")
            writer.write("QUIT\r\n")
            writer.flush()
            val response = generateSequence { reader.readLine() }.take(20).joinToString("\n")
            val progress = Regex("PROGRESS=(\\d+)").find(response)?.groupValues?.get(1)?.toIntOrNull()
            if (progress != null) {
                bootstrapPercent = progress
                status = if (progress >= 100) "running" else "starting"
                message = "Bootstrapped $progress%"
            }
        }
    }

    private fun checkTorExit(socksPort: Int): Map<String, Any?> {
        val ipInfo = JSONObject(
            readHttpThroughSocks(
                "http://ip-api.com/json/?fields=status,countryCode,query",
                socksPort,
            )
        )
        return mapOf(
            "ok" to true,
            "ip" to ipInfo.optString("query"),
            "countryCode" to ipInfo.optString("countryCode"),
        )
    }

    private fun readTraffic(controlPort: Int): Map<String, Any?> {
        if (status == "disabled") {
            return mapOf("ok" to true, "up" to 0L, "down" to 0L)
        }
        Socket().use { socket ->
            socket.connect(InetSocketAddress("127.0.0.1", controlPort), 1000)
            val writer = socket.getOutputStream().bufferedWriter()
            val reader = socket.getInputStream().bufferedReader()
            writer.write("AUTHENTICATE\r\n")
            writer.write("GETINFO traffic/read traffic/written\r\n")
            writer.write("QUIT\r\n")
            writer.flush()
            val response = generateSequence { reader.readLine() }.take(20).joinToString("\n")
            val read = Regex("traffic/read=(\\d+)").find(response)
                ?.groupValues
                ?.get(1)
                ?.toLongOrNull() ?: 0L
            val written = Regex("traffic/written=(\\d+)").find(response)
                ?.groupValues
                ?.get(1)
                ?.toLongOrNull() ?: 0L
            return mapOf("ok" to true, "up" to written, "down" to read)
        }
    }

    private fun readHttpThroughSocks(url: String, socksPort: Int): String {
        val uri = URI(url)
        val host = uri.host
        val port = if (uri.port > 0) uri.port else 80
        val path = buildString {
            append(if (uri.rawPath.isNullOrEmpty()) "/" else uri.rawPath)
            if (!uri.rawQuery.isNullOrEmpty()) append("?${uri.rawQuery}")
        }
        val plainSocket = openSocks5Socket(socksPort, host, port)
        return plainSocket.use { socket ->
            val writer = socket.getOutputStream().bufferedWriter()
            writer.write("GET $path HTTP/1.0\r\n")
            writer.write("Host: $host\r\n")
            writer.write("User-Agent: Bettbox\r\n")
            writer.write("Connection: close\r\n")
            writer.write("\r\n")
            writer.flush()

            val response = socket.inputStream.bufferedReader().use { it.readText() }
            val bodyIndex = response.indexOf("\r\n\r\n")
            if (bodyIndex >= 0) response.substring(bodyIndex + 4) else response
        }
    }

    private fun openSocks5Socket(socksPort: Int, host: String, port: Int): Socket {
        val socket = Socket()
        socket.soTimeout = 15000
        socket.connect(InetSocketAddress("127.0.0.1", socksPort), 15000)
        val input = socket.getInputStream()
        val output = socket.getOutputStream()

        output.write(byteArrayOf(0x05, 0x01, 0x00))
        output.flush()
        val authResponse = input.readNBytesCompat(2)
        if (authResponse.size != 2 || authResponse[0].toInt() != 0x05 || authResponse[1].toInt() != 0x00) {
            socket.close()
            throw IllegalStateException("Tor SOCKS authentication negotiation failed")
        }

        val hostBytes = host.toByteArray(Charsets.UTF_8)
        output.write(byteArrayOf(0x05, 0x01, 0x00, 0x03, hostBytes.size.toByte()))
        output.write(hostBytes)
        output.write(byteArrayOf(((port shr 8) and 0xff).toByte(), (port and 0xff).toByte()))
        output.flush()

        val header = input.readNBytesCompat(4)
        if (header.size != 4 || header[1].toInt() != 0x00) {
            socket.close()
            throw IllegalStateException("Tor SOCKS connect failed")
        }
        val addressLength = when (header[3].toInt()) {
            0x01 -> 4
            0x03 -> input.read()
            0x04 -> 16
            else -> throw IllegalStateException("Tor SOCKS returned unknown address type")
        }
        input.readNBytesCompat(addressLength + 2)
        return socket
    }

    private fun java.io.InputStream.readNBytesCompat(length: Int): ByteArray {
        val buffer = ByteArray(length)
        var offset = 0
        while (offset < length) {
            val read = read(buffer, offset, length - offset)
            if (read < 0) break
            offset += read
        }
        return if (offset == length) buffer else buffer.copyOf(offset)
    }

    private fun effectiveBridges(options: TorStartOptions): List<String> {
        val cleanedCustom = options.customBridges
            .flatMap { it.split(Regex("\\r\\n?|\\n")) }
            .flatMap { it.split(Regex("(?=(?:obfs4|snowflake|meek_lite|meek)\\s+)")) }
            .map { it.trim() }
            .filter { it.isNotEmpty() }
        if (options.customBridgesEnabled && cleanedCustom.isNotEmpty()) return cleanedCustom

        val mode = options.bridgeMode.lowercase()
        return runCatching {
            val array = JSONObject(
                appContext.assets.open("tor/builtin-bridges.json")
                    .bufferedReader()
                    .use { it.readText() }
            ).optJSONArray(mode) ?: return@runCatching emptyList()
            buildList {
                for (index in 0 until array.length()) {
                    array.optString(index).trim().takeIf { it.isNotEmpty() }?.let(::add)
                }
            }
        }.getOrElse {
            Log.w(TAG, "Failed to load builtin bridges for $mode: ${it.message}")
            if (mode == "obfs4") DEFAULT_OBFS4_BRIDGES else emptyList()
        }
    }

    private fun statusMap(): Map<String, Any?> = mapOf(
        "status" to status,
        "message" to message,
        "bridgeMode" to lastOptions?.bridgeMode,
        "upstreamSocksPort" to lastOptions?.upstreamSocksPort,
        "socksPort" to (lastOptions?.socksPort ?: 19050),
        "controlPort" to (lastOptions?.controlPort ?: 19051),
        "dnsPort" to (lastOptions?.dnsPort ?: 19053),
        "bootstrapPercent" to bootstrapPercent,
    )

}
