package com.testapk.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.util.Log

class InstallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)
        val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE)
        val packageName = intent.getStringExtra("my_package_name") ?: intent.getStringExtra(PackageInstaller.EXTRA_PACKAGE_NAME)
        Log.d("InstallReceiver", "Installation status: $status, message: $message, package: $packageName")
        
        // Forward the status to MainActivity's dynamic receiver
        val localIntent = Intent("com.testapk.app.INSTALL_STATUS_UPDATE").apply {
            putExtra(PackageInstaller.EXTRA_STATUS, status)
            putExtra(PackageInstaller.EXTRA_STATUS_MESSAGE, message)
            putExtra(PackageInstaller.EXTRA_PACKAGE_NAME, packageName)
            setPackage(context.packageName)
        }
        context.sendBroadcast(localIntent)
        
        when (status) {
            PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                val confirmIntent = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(Intent.EXTRA_INTENT)
                }
                if (confirmIntent != null) {
                    confirmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(confirmIntent)
                }
            }
            PackageInstaller.STATUS_SUCCESS -> {
                Log.d("InstallReceiver", "Installation succeeded!")
            }
            else -> {
                Log.e("InstallReceiver", "Installation failed: $message")
            }
        }
    }
}
