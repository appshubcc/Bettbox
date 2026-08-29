package dev.fluttercommunity.plus.packageinfo

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

/** PackageInfoPlugin  */
class PackageInfoPlugin : MethodCallHandler, FlutterPlugin {
    private var applicationContext: Context? = null
    private var methodChannel: MethodChannel? = null

    /** Plugin registration.  */
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        methodChannel!!.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        applicationContext = null
        methodChannel!!.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (call.method == "getAll") {
                val packageManager = applicationContext!!.packageManager
                val info = packageManager.getPackageInfo(applicationContext!!.packageName, 0)

                val buildSignature = getBuildSignature(packageManager)

                val installerPackage = getInstallerPackageName()

                val infoMap = HashMap<String, String>()
                infoMap.apply {
                    put("appName", info.applicationInfo.loadLabel(packageManager).toString())
                    put("packageName", applicationContext!!.packageName)
                    put("version", info.versionName)
                    put("buildNumber", getLongVersionCode(info).toString())
                    if (buildSignature != null) put("buildSignature", buildSignature)
                    if (installerPackage != null) put("installerStore", installerPackage)
                }.also { resultingMap ->
                    result.success(resultingMap)
                }
            } else {
                result.notImplemented()
            }
        } catch (ex: PackageManager.NameNotFoundException) {
            result.error("Name not found", ex.message, null)
        }
    }

    /**
     * Using initiatingPackageName on Android 11 and newer because it can't be changed
     * https://developer.android.com/reference/android/content/pm/InstallSourceInfo#getInitiatingPackageName()
     */
    private fun getInstallerPackageName(): String? {
        val packageManager = applicationContext!!.packageManager
        val packageName = applicationContext!!.packageName
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            packageManager.getInstallSourceInfo(packageName).initiatingPackageName
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstallerPackageName(packageName)
        }
    }

    @Suppress("deprecation")
    private fun getLongVersionCode(info: PackageInfo): Long {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            info.versionCode.toLong()
        }
    }

    @Suppress("deprecation", "PackageManagerGetSignatures")
    private fun getBuildSignature(pm: PackageManager): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val packageInfo = pm.getPackageInfo(
                    applicationContext!!.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
                val signingInfo = packageInfo.signingInfo ?: return null

                if (signingInfo.hasMultipleSigners()) {
                    signatureToSha1(signingInfo.apkContentsSigners.first().toByteArray())
                } else {
                    signatureToSha1(signingInfo.signingCertificateHistory.first().toByteArray())
                }
            } else {
                val packageInfo = pm.getPackageInfo(
                    applicationContext!!.packageName,
                    PackageManager.GET_SIGNATURES
                )
                val signatures = packageInfo.signatures

                if (signatures.isNullOrEmpty() || packageInfo.signatures.first() == null) {
                    null
                } else {
                    signatureToSha1(signatures.first().toByteArray())
                }
            }
        } catch (e: PackageManager.NameNotFoundException) {
            null
        } catch (e: NoSuchAlgorithmException) {
            null
        }
    }

    // Credits https://gist.github.com/scottyab/b849701972d57cf9562e
    @Throws(NoSuchAlgorithmException::class)
    private fun signatureToSha1(sig: ByteArray): String {
        val digest = MessageDigest.getInstance("SHA1")
        digest.update(sig)
        val hashText = digest.digest()
        return bytesToHex(hashText)
    }

    // Credits https://gist.github.com/scottyab/b849701972d57cf9562e
    private fun bytesToHex(bytes: ByteArray): String {
        val hexArray = charArrayOf(
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
        )
        val hexChars = CharArray(bytes.size * 2)
        var v: Int
        for (j in bytes.indices) {
            v = bytes[j].toInt() and 0xFF
            hexChars[j * 2] = hexArray[v ushr 4]
            hexChars[j * 2 + 1] = hexArray[v and 0x0F]
        }
        return String(hexChars)
    }

    companion object {
        private const val CHANNEL_NAME = "dev.fluttercommunity.plus/package_info"
    }
}
