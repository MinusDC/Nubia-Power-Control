package com.powercontrol.power_control

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled())
                }

                "openAccessibilitySettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(true)
                    } catch (_: ActivityNotFoundException) {
                        result.success(false)
                    } catch (_: SecurityException) {
                        result.success(false)
                    }
                }

                "openPowerMenu" -> {
                    if (!isAccessibilityServiceEnabled()) {
                        result.error(
                            "accessibility_disabled",
                            "The Power Control accessibility service is disabled.",
                            null,
                        )
                    } else {
                        when (PowerMenuAccessibilityService.openPowerMenu()) {
                            null -> result.error(
                                "service_unavailable",
                                "The accessibility service is not connected.",
                                null,
                            )

                            true -> result.success(true)
                            false -> result.error(
                                "power_menu_unavailable",
                                "Android did not open the system power menu.",
                                null,
                            )
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val enabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED,
            0,
        ) == 1
        if (!enabled) return false

        val expectedService = ComponentName(
            this,
            PowerMenuAccessibilityService::class.java,
        )
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false

        return enabledServices.split(':').any { flattenedComponent ->
            ComponentName.unflattenFromString(flattenedComponent) == expectedService
        }
    }

    private companion object {
        const val CHANNEL_NAME = "com.powercontrol.power_control/power"
    }
}
