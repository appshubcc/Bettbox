package com.appshub.bettbox.plugins

import android.Manifest
import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.ComponentInfo
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import android.provider.Settings
import android.util.Base64
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.core.content.getSystemService
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import com.appshub.bettbox.BettboxApplication
import com.appshub.bettbox.GlobalState
import com.appshub.bettbox.R
import com.appshub.bettbox.extensions.awaitResult
import com.appshub.bettbox.extensions.getActionIntent
import com.appshub.bettbox.models.Package
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.lang.ref.WeakReference
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.util.concurrent.ConcurrentHashMap
import android.content.res.Configuration
import android.net.Uri
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable

class AppPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private var activityRef: WeakReference<Activity>? = null
    private var cachedTaskId: Int? = null
    private lateinit var channel: MethodChannel
    private lateinit var scope: CoroutineScope
    private var vpnCallBack: (() -> Unit)? = null
    private val packages = mutableListOf<Package>()
    private val chinaPackageCache = ConcurrentHashMap<String, Boolean>()

    private val iconCacheDir by lazy {
        File(BettboxApplication.getAppContext().cacheDir, "app_icons").apply {
            if (!exists()) mkdirs()
        }
    }

    companion object {
        private const val ICON_SIZE_DP = 48
        private const val VPN_PERMISSION_REQUEST_CODE = 1001
        private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002
        private const val CACHE_MAX_FILES = 500
        private const val PNG_MAGIC_SIZE = 8

        private val SKIP_PREFIX_LIST = listOf(
            "com.google", "com.android.chrome", "com.android.vending", "com.facebook",
            "com.instagram", "com.whatsapp", "com.twitter", "com.linkedin", "com.snapchat",
            "com.amazon", "com.microsoft", "com.apple", "com.dropbox", "com.mozilla",
            "com.brave", "com.duckduckgo", "com.vivaldi", "com.kiwibrowser",
            "org.torproject.torbrowser", "com.opera.browser", "com.lemon.browser",
            "net.waterfox", "ch.protonmail", "org.thoughtcrime.securesms", "org.telegram",
            "com.surfshark", "com.netflix", "com.spotify", "tv.twitch", "com.hulu",
            "com.disney", "com.hbo", "com.primevideo", "com.zhiliaoapp.musically",
            "com.nytimes", "bbc.mobile", "com.wsj", "com.bloomberg", "com.medium",
            "com.quora", "com.github", "io.github", "com.slack", "com.notion", "us.zoom",
            "com.discord", "com.reddit", "com.pinterest", "com.tumblr", "jp.naver.line",
            "com.skype", "com.box", "org.wikipedia", "com.gitlab", "com.openai",
            "com.valvesoftware", "com.roblox", "com.ea.gp", "com.ubisoft",
            "com.sogou.activity.src", "com.qihoo.browser", "com.qihoo.haosou",
            "com.liebao", "com.mx.browser", "com.browser2345", "com.ijinshan.browser",
            "com.quark.browser", "com.ylmf.androidclient", "mark.via", "com.xbrowser.play",
            "com.mycompany.app.soulbrowser", "com.hshentong.alook", "info.bmmk.mbrowser",
            "com.rainsee.browser", "com.liuzh.browser", "com.yuzhe.browser",
            "org.easyweb.browser", "any.browser", "us.spotco.fennec_dos",
            "app.grapheneos.vanadium", "org.ironfoxoss", "com.samsung.android.app.sbrowser",
            "com.mi.global.browser", "com.android.browser", "com.huawei.browser",
            "com.hihonor.browser", "com.heytap.browser", "com.coloros.browser",
            "com.oppo.browser", "com.vivo.browser", "com.bbk.browser", "com.meizu.browser",
            "com.meizu.mbrowser", "com.lenovo.browser", "com.zte.browser", "com.gionee.browser"
        )

        private val CHINA_APP_PREFIX_LIST = listOf(
            "com.tencent", "com.alibaba", "com.ali", "com.alipay", "com.taobao", "com.baidu",
            "com.iqiyi", "com.bytedance", "com.ss.android", "com.kuaishou", "com.smile.gifmaker",
            "com.xunmeng", "com.pinduoduo", "com.sankuai", "com.meituan", "com.jingdong",
            "com.jd", "tv.danmaku", "com.sina", "com.weibo", "com.sohu", "com.netease",
            "com.zhihu", "com.xingin", "com.huawei", "com.xiaomi", "com.miui", "com.oppo",
            "com.coloros", "com.oplus", "andes.oplus", "com.vivo", "com.bbk", "com.iqoo",
            "com.meizu", "com.flyme", "com.gionee", "cn.nubia", "com.zte", "com.lenovo",
            "com.oneplus", "com.qihoo", "com.360", "com.ijiami", "com.bangcle", "com.secneo",
            "com.kiwisec", "com.stub", "com.wrapper", "cn.securitystack", "com.mogosec",
            "com.secoen", "com.secshell", "com.umeng", "com.igexin", "cn.jpush", "cn.jiguang",
            "com.bugly", "com.mob", "cn.wps", "com.kingsoft", "com.xunlei", "com.unionpay",
            "com.cainiao", "com.sf", "com.sdu", "com.xiaojukeji", "com.autonavi", "com.amap",
            "com.chinamobile", "com.chinaunicom", "com.chinatelecom", "com.icbc", "com.ccb",
            "com.cmbchina", "com.mx", "com.qq", "app.eleven.com.fastfiletransfer",
            "org.localsend.localsend_app"
        )

        private val CHINA_APP_REGEX by lazy {
            ("(" + CHINA_APP_PREFIX_LIST.joinToString("|").replace(".", "\\.") + ").*").toRegex()
        }
    }

    private var isBlockNotification = false
    private var isActivityAttached = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app")
        channel.setMethodCallHandler(this)
        scope.launch(Dispatchers.IO) { cleanIconCache() }
    }

    private fun initShortcuts(label: String) {
        val iconRes = if (isSystemInDarkMode()) R.mipmap.ic_launcher_round else R.mipmap.ic_launcher_round_light
        val shortcut = ShortcutInfoCompat.Builder(BettboxApplication.getAppContext(), "toggle")
            .setShortLabel(label)
            .setIcon(IconCompat.createWithResource(BettboxApplication.getAppContext(), iconRes))
            .setIntent(BettboxApplication.getAppContext().getActionIntent("CHANGE"))
            .build()
        ShortcutManagerCompat.setDynamicShortcuts(BettboxApplication.getAppContext(), listOf(shortcut))
    }

    private fun isSystemInDarkMode(): Boolean {
        val nightModeFlags = BettboxApplication.getAppContext().resources.configuration.uiMode and
            Configuration.UI_MODE_NIGHT_MASK
        return nightModeFlags == Configuration.UI_MODE_NIGHT_YES
    }

    private fun isAndroidTV(): Boolean {
        val uiMode = BettboxApplication.getAppContext().resources.configuration.uiMode
        return (uiMode and Configuration.UI_MODE_TYPE_MASK) == Configuration.UI_MODE_TYPE_TELEVISION
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    private fun tip(message: String?) {
        if (GlobalState.flutterEngine == null) {
            Toast.makeText(BettboxApplication.getAppContext(), message, Toast.LENGTH_LONG).show()
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "moveTaskToBack" -> {
                activityRef?.get()?.moveTaskToBack(true)
                result.success(true)
            }
            "updateExcludeFromRecents" -> {
                updateExcludeFromRecents(call.argument<Boolean>("value"))
                result.success(true)
            }
            "initShortcuts" -> {
                initShortcuts(call.arguments as String)
                result.success(true)
            }
            "getPackages" -> scope.launch {
                val forceRefresh = call.argument<Boolean>("forceRefresh") ?: false
                runCatching { result.success(getPackagesToList(forceRefresh)) }
                    .onFailure { result.error("GET_PACKAGES_FAILED", it.message, null) }
            }
            "getChinaPackageNames" -> scope.launch {
                runCatching { result.success(getChinaPackageNamesList()) }
                    .onFailure { result.error("GET_CHINA_PACKAGES_FAILED", it.message, null) }
            }
            "getPackageIcon" -> scope.launch {
                val packageName = call.argument<String>("packageName")
                val forceRefresh = call.argument<Boolean>("forceRefresh") ?: false
                val icon = runCatching {
                    packageName?.let { 
                        getPackageIconBytes(it, forceRefresh) 
                    } ?: getDefaultIconBytes()
                }.getOrNull() ?: getDefaultIconBytes()
                result.success(icon)
            }
            "tip" -> {
                tip(call.argument<String>("message"))
                result.success(true)
            }
            "openFile" -> {
                openFile(call.argument<String>("path")!!)
                result.success(true)
            }
            "getSelfLastUpdateTime" -> {
                result.success(getSelfLastUpdateTime())
            }
            "isIgnoringBatteryOptimizations" -> {
                result.success(isIgnoringBatteryOptimizations())
            }
            "requestIgnoreBatteryOptimizations" -> {
                requestIgnoreBatteryOptimizations()
                result.success(true)
            }
            "setLauncherIcon" -> {
                setLauncherIcon(call.argument<Boolean>("useLightIcon") ?: false)
                result.success(true)
            }
            "hasPackageListPermission" -> {
                result.success(hasPackageListPermission())
            }
            "requestPackageListPermission" -> {
                requestPackageListPermission()
                result.success(true)
            }
            "hasCameraPermission" -> {
                result.success(hasCameraPermission())
            }
            "openAppSettings" -> {
                openAppSettings()
                result.success(true)
            }
            "isAndroidTV" -> {
                result.success(isAndroidTV())
            }
            else -> result.notImplemented()
        }
    }

    private fun openFile(path: String) {
        val context = BettboxApplication.getAppContext()
        val file = File(path)
        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileProvider",
            file
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "text/plain")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        runCatching { context.startActivity(intent) }
    }

    private fun updateExcludeFromRecents(value: Boolean?) {
        val am = BettboxApplication.getAppContext().getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
        val task = am?.appTasks?.firstOrNull { task ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                task.taskInfo.taskId == activityRef?.get()?.taskId
            } else {
                @Suppress("DEPRECATION")
                task.taskInfo.id == activityRef?.get()?.taskId
            }
        }

        when (value) {
            true -> task?.setExcludeFromRecents(value)
            false -> task?.setExcludeFromRecents(value)
            null -> task?.setExcludeFromRecents(false)
        }
    }

    private fun getIconSizePx(): Int {
        val density = BettboxApplication.getAppContext().resources.displayMetrics.density
        return (ICON_SIZE_DP * density).toInt().coerceAtLeast(1)
    }

    private fun drawableToPngBytes(drawable: Drawable, sizePx: Int): ByteArray {
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, sizePx, sizePx)
        drawable.draw(canvas)
        return java.io.ByteArrayOutputStream().use { outputStream ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 80, outputStream)
            bitmap.recycle()
            outputStream.toByteArray()
        }
    }

    private fun getDefaultIconBytes(): ByteArray? = runCatching {
        drawableToPngBytes(BettboxApplication.getAppContext().packageManager.defaultActivityIcon, getIconSizePx())
    }.getOrNull()

    private fun isPngBytes(bytes: ByteArray): Boolean {
        if (bytes.size < PNG_MAGIC_SIZE) return false
        val magic = byteArrayOf(0x89.toByte(), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
        return bytes.take(PNG_MAGIC_SIZE).toByteArray().contentEquals(magic)
    }

    private suspend fun getPackageIconBytes(packageName: String, forceRefresh: Boolean = false): ByteArray? =
        withContext(Dispatchers.IO) {
            val pm = BettboxApplication.getAppContext().packageManager ?: return@withContext null
            runCatching {
                val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
                } else {
                    pm.getPackageInfo(packageName, 0)
                }
                val lastUpdateTime = packageInfo?.lastUpdateTime ?: 0L
                val cacheKey = "${packageName}_${lastUpdateTime}"
                val cacheFile = File(iconCacheDir, cacheKey)

                if (forceRefresh && cacheFile.exists() && (System.currentTimeMillis() - lastUpdateTime) < 24 * 60 * 60 * 1000) {
                    cacheFile.delete()
                }

                if (cacheFile.exists() && cacheFile.length() > 0) {
                    val cachedBytes = cacheFile.readBytes()
                    if (isPngBytes(cachedBytes)) return@withContext cachedBytes
                    cacheFile.delete()
                }

                iconCacheDir.listFiles()?.forEach { if (it.name.startsWith("${packageName}_") && it.name != cacheKey) it.delete() }

                pm.getApplicationIcon(packageName)?.let { drawable ->
                    val bytes = drawableToPngBytes(drawable, getIconSizePx())
                    runCatching { cacheFile.writeBytes(bytes) }
                    return@withContext bytes
                }
            }
            null
        }

    private suspend fun getPackages(forceRefresh: Boolean = false): List<Package> = withContext(Dispatchers.IO) {
        if (forceRefresh) packages.clear()
        if (packages.isNotEmpty()) return@withContext packages
        val pm = BettboxApplication.getAppContext().packageManager ?: return@withContext emptyList()
        val selfPackageName = BettboxApplication.getAppContext().packageName

        packages.addAll(pm.getInstalledApplications(PackageManager.GET_META_DATA).mapNotNull { appInfo ->
            val packageName = appInfo.packageName ?: return@mapNotNull null
            if (packageName == selfPackageName) return@mapNotNull null

            val label = runCatching { appInfo.loadLabel(pm).toString() }.getOrDefault(packageName)
            val system = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            val internet = runCatching {
                pm.checkPermission(Manifest.permission.INTERNET, packageName) == PackageManager.PERMISSION_GRANTED
            }.getOrDefault(false)
            val lastUpdateTime = appInfo.sourceDir?.let { File(it).lastModified() } ?: 0L

            Package(packageName, label, system, internet, lastUpdateTime)
        })
        packages
    }

    private suspend fun getPackagesToList(forceRefresh: Boolean = false): List<Map<String, Any>> =
        getPackages(forceRefresh).map { mapOf("packageName" to it.packageName, "label" to it.label, "system" to it.system, "internet" to it.internet, "lastUpdateTime" to it.lastUpdateTime) }

    private suspend fun getChinaPackageNamesList(): List<String> =
        getPackages().map { it.packageName }.filter { isChinaPackage(it) }

    private fun cleanIconCache() {
        runCatching {
            iconCacheDir.listFiles()?.takeIf { it.size > CACHE_MAX_FILES }?.let { files ->
                files.sortedBy { it.lastModified() }.take(files.size - CACHE_MAX_FILES).forEach { it.delete() }
            }
        }
    }

    fun requestVpnPermission(callBack: () -> Unit) {
        vpnCallBack = callBack
        val intent = VpnService.prepare(BettboxApplication.getAppContext())
        if (intent != null) {
            activityRef?.get()?.startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
            return
        }
        vpnCallBack?.invoke()
    }

    fun requestNotificationsPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (isBlockNotification || activityRef?.get() == null) return
        if (ContextCompat.checkSelfPermission(BettboxApplication.getAppContext(), Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) return
        activityRef?.get()?.let {
            ActivityCompat.requestPermissions(it, arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST_CODE)
        }
    }

    suspend fun getText(text: String): String? = withContext(Dispatchers.Default) {
        channel.awaitResult<String>("getText", text)
    }

    private fun isChinaPackage(packageName: String): Boolean =
        chinaPackageCache.getOrPut(packageName) { isChinaPackageInternal(packageName) }

    private fun isChinaPackageInternal(packageName: String): Boolean {
        val context = BettboxApplication.getAppContext()
        val pm = context.packageManager ?: return false
        if (SKIP_PREFIX_LIST.any { packageName == it || packageName.startsWith("$it.") }) return false
        if (packageName.matches(CHINA_APP_REGEX)) return true
        if (isChinaCertificate(packageName, pm)) return true

        val flags = PackageManager.GET_ACTIVITIES or PackageManager.GET_SERVICES or PackageManager.GET_RECEIVERS or PackageManager.GET_PROVIDERS
        runCatching {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(flags.toLong()))
            } else {
                pm.getPackageInfo(packageName, flags)
            }
            val components = mutableListOf<ComponentInfo>().apply {
                packageInfo.services?.let { addAll(it) }
                packageInfo.activities?.let { addAll(it) }
                packageInfo.receivers?.let { addAll(it) }
                packageInfo.providers?.let { addAll(it) }
            }
            if (components.any { it.name.matches(CHINA_APP_REGEX) }) return true
        }
        return false
    }

    private fun isChinaCertificate(packageName: String, pm: PackageManager): Boolean = runCatching {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            pm.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
        } else {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
        }
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.signingInfo?.apkContentsSigners
        } else {
            @Suppress("DEPRECATION")
            packageInfo.signatures
        }
        signatures?.any { signature ->
            val cert = CertificateFactory.getInstance("X.509")
                .generateCertificate(java.io.ByteArrayInputStream(signature.toByteArray()))
            cert is X509Certificate && (cert.subjectDN.name.contains("C=CN", ignoreCase = true) ||
                cert.subjectDN.name.contains("C=86", ignoreCase = true))
        } == true
    }.getOrDefault(false)

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityRef = WeakReference(binding.activity)
        if (!isActivityAttached) {
            isActivityAttached = true
            binding.addActivityResultListener(::onActivityResult)
            binding.addRequestPermissionsResultListener(::onRequestPermissionsResultListener)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityRef = null
    }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityRef = WeakReference(binding.activity)
    }
    override fun onDetachedFromActivity() {
        channel.invokeMethod("exit", null)
        activityRef = null
        cachedTaskId = null
        isActivityAttached = false
    }

    private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (!isActivityAttached) return false
        if (requestCode == VPN_PERMISSION_REQUEST_CODE && resultCode == FlutterActivity.RESULT_OK) {
            GlobalState.initServiceEngine()
            vpnCallBack?.invoke()
        }
        return true
    }

    private fun onRequestPermissionsResultListener(requestCode: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
        if (!isActivityAttached) return false
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) isBlockNotification = true
        return true
    }

    private fun isIgnoringBatteryOptimizations(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = BettboxApplication.getAppContext().getSystemService(android.content.Context.POWER_SERVICE) as? android.os.PowerManager
            powerManager?.isIgnoringBatteryOptimizations(BettboxApplication.getAppContext().packageName) ?: false
        } else true

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${BettboxApplication.getAppContext().packageName}")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        runCatching { BettboxApplication.getAppContext().startActivity(intent) }
            .onFailure {
                runCatching {
                    BettboxApplication.getAppContext().startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    })
                }
            }
    }

    private fun setLauncherIcon(useLightIcon: Boolean) {
        val context = BettboxApplication.getAppContext()
        val pm = context.packageManager
        val packageName = context.packageName
        val defaultComponent = android.content.ComponentName(packageName, "com.appshub.bettbox.MainActivity")
        val lightComponent = android.content.ComponentName(packageName, "com.appshub.bettbox.MainActivityLight")

        if (useLightIcon) {
            pm.setComponentEnabledSetting(lightComponent, PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP)
            pm.setComponentEnabledSetting(defaultComponent, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        } else {
            pm.setComponentEnabledSetting(defaultComponent, PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP)
            pm.setComponentEnabledSetting(lightComponent, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        }
        com.appshub.bettbox.services.NotificationComponentCache.invalidate()
        VpnPlugin.updateNotificationIcon()
    }

    private fun hasPackageListPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return true
        val context = BettboxApplication.getAppContext()
        val pm = context.packageManager
        return arrayOf("com.android.settings", "com.android.systemui").any { pkg ->
            runCatching {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    pm.getPackageInfo(pkg, PackageManager.PackageInfoFlags.of(0))
                } else {
                    pm.getPackageInfo(pkg, 0)
                }
                true
            }.getOrDefault(false)
        }
    }

    private fun requestPackageListPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) openAppSettings()
    }

    private fun hasCameraPermission(): Boolean =
        ContextCompat.checkSelfPermission(BettboxApplication.getAppContext(), Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:${BettboxApplication.getAppContext().packageName}")
        }
        activityRef?.get()?.startActivity(intent) ?: run {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            BettboxApplication.getAppContext().startActivity(intent)
        }
    }

    private fun getSelfLastUpdateTime(): Long {
        val context = BettboxApplication.getAppContext()
        val pm = context.packageManager
        return runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm?.getPackageInfo(context.packageName, PackageManager.PackageInfoFlags.of(0))
            } else {
                pm?.getPackageInfo(context.packageName, 0)
            }?.lastUpdateTime
        }.getOrDefault(0L) ?: 0L
    }
}
