package com.testapk.app

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.testapk.app/app_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val installed = isAppInstalled(packageName)
                        result.success(installed)
                    } else {
                        result.error("BAD_ARGS", "Package name is null", null)
                    }
                }
                "getInstalledVersionInfo" -> {
                    val packageName = call.argument<String>("packageName")
                    android.util.Log.d("MainActivity", "getInstalledVersionInfo called for package: $packageName")
                    if (packageName != null) {
                        val info = getInstalledVersionInfo(packageName)
                        android.util.Log.d("MainActivity", "getInstalledVersionInfo returned: $info")
                        result.success(info)
                    } else {
                        result.error("BAD_ARGS", "Package name is null", null)
                    }
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val launched = launchApp(packageName)
                        result.success(launched)
                    } else {
                        result.error("BAD_ARGS", "Package name is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledVersionInfo(packageName: String): Map<String, Any> {
        return try {
            val pInfo = packageManager.getPackageInfo(packageName, 0)
            val versionCode = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                (pInfo.longVersionCode and 0xFFFFFFFFL).toInt()
            } else {
                @Suppress("DEPRECATION")
                pInfo.versionCode
            }
            val versionName = pInfo.versionName ?: ""
            mapOf("versionCode" to versionCode, "versionName" to versionName)
        } catch (e: PackageManager.NameNotFoundException) {
            mapOf("versionCode" to -1, "versionName" to "")
        }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun launchApp(packageName: String): Boolean {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        return if (intent != null) {
            startActivity(intent)
            true
        } else {
            false
        }
    }
}
