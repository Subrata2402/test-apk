package com.testapk.app

import android.app.PendingIntent
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageInstaller
import java.io.File
import java.io.FileInputStream
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.os.Bundle

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.testapk.app/app_launcher"
    private var channel: MethodChannel? = null

    private val installStatusReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)
            val packageName = intent.getStringExtra(PackageInstaller.EXTRA_PACKAGE_NAME)
            val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE)
            
            android.util.Log.d("MainActivity", "Dynamic Install Status: $status, package: $packageName, message: $message")
            
            if (packageName != null) {
                runOnUiThread {
                    channel?.invokeMethod("onInstallStatusChanged", mapOf(
                        "packageName" to packageName,
                        "status" to status,
                        "message" to message
                    ))
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filter = IntentFilter("com.testapk.app.INSTALL_STATUS_UPDATE")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(installStatusReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(installStatusReceiver, filter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(installStatusReceiver)
        } catch (e: Exception) {
            // Ignore
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
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
                "showNotification" -> {
                    val title = call.argument<String>("title")
                    val body = call.argument<String>("body")
                    if (title != null && body != null) {
                        showNotification(title, body)
                        result.success(true)
                    } else {
                        result.error("BAD_ARGS", "Title or body is null", null)
                    }
                }
                "installApk" -> {
                    val apkPath = call.argument<String>("apkPath")
                    if (apkPath != null) {
                        installApk(apkPath, result)
                    } else {
                        result.error("BAD_ARGS", "APK path is null", null)
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

    private fun showNotification(title: String, body: String) {

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val channelId = "general"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "General",
                NotificationManager.IMPORTANCE_HIGH
            )
            manager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        manager.notify(1, notification)
    }

    private fun installApk(apkPath: String, result: MethodChannel.Result) {
        val file = File(apkPath)
        if (!file.exists()) {
            result.error("FILE_NOT_FOUND", "APK file not found at $apkPath", null)
            return
        }

        val apkPackageName = try {
            packageManager.getPackageArchiveInfo(apkPath, 0)?.packageName
        } catch (e: Exception) {
            null
        }

        try {
            val packageInstaller = packageManager.packageInstaller
            val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                params.setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
            }

            val sessionId = packageInstaller.createSession(params)
            val session = packageInstaller.openSession(sessionId)

            val out = session.openWrite("TestAPKInstall", 0, file.length())
            val inputStream = FileInputStream(file)
            val buffer = ByteArray(65536)
            var c: Int
            while (inputStream.read(buffer).also { c = it } != -1) {
                out.write(buffer, 0, c)
            }
            session.fsync(out)
            inputStream.close()
            out.close()

            val intent = Intent(this, InstallReceiver::class.java).apply {
                action = "com.testapk.app.INSTALL_STATUS"
                putExtra("my_package_name", apkPackageName)
            }

            val pendingIntent = PendingIntent.getBroadcast(
                this,
                sessionId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
            )

            session.commit(pendingIntent.intentSender)
            session.close()
            result.success(true)
        } catch (e: Exception) {
            result.error("INSTALL_ERROR", e.message, null)
        }
    }
}
