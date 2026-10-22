package com.powercontrol.power_control

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import java.lang.ref.WeakReference

class PowerMenuAccessibilityService : AccessibilityService() {
    @Volatile
    private var connected = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        connected = true
        synchronized(serviceLock) {
            activeService = WeakReference(this)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        connected = false
        synchronized(serviceLock) {
            if (activeService?.get() === this) {
                activeService = null
            }
        }
        super.onDestroy()
    }

    private fun showPowerMenu(): Boolean {
        return connected && performGlobalAction(GLOBAL_ACTION_POWER_DIALOG)
    }

    companion object {
        private val serviceLock = Any()

        @Volatile
        private var activeService: WeakReference<PowerMenuAccessibilityService>? = null

        fun openPowerMenu(): Boolean? = synchronized(serviceLock) {
            val service = activeService?.get()
            if (service == null || !service.connected) {
                activeService = null
                null
            } else {
                service.showPowerMenu()
            }
        }
    }
}
