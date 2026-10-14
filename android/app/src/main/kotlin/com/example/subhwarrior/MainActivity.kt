package com.subhwarrior.app

import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showCallOverLockScreenIfNeeded(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        showCallOverLockScreenIfNeeded(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canUseFullScreenIntent" -> result.success(canUseFullScreenIntent())
                    "endCall" -> {
                        val id = call.argument<Int>("notificationId")
                        // Only the posted notification: the plugin's own cancel
                        // would also drop the daily schedule, and with it
                        // tomorrow's call.
                        if (id != null) NotificationManagerCompat.from(this).cancel(id)
                        setOverLockScreen(false)
                        if (call.argument<Boolean>("unlock") == true) {
                            requestUnlock()
                        } else {
                            moveTaskToBack(true)
                        }
                        result.success(null)
                    }
                    "releaseLockScreen" -> {
                        setOverLockScreen(false)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * The Fajr call's full-screen intent lands here with the call's payload.
     * Showing over the keyguard has to happen now, natively: waiting for
     * Flutter to boot would leave the call screen behind the lock screen
     * while the alarm is already ringing.
     */
    private fun showCallOverLockScreenIfNeeded(intent: Intent?) {
        if (intent?.getStringExtra(PAYLOAD_EXTRA) == FAJR_CALL_PAYLOAD) {
            setOverLockScreen(true)
        }
    }

    private fun setOverLockScreen(enabled: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(enabled)
            setTurnScreenOn(enabled)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (enabled) window.addFlags(flags) else window.clearFlags(flags)
        }
    }

    private fun requestUnlock() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguard.requestDismissKeyguard(this, null)
        }
    }

    /**
     * Android 14 gates full-screen intents behind a per-app switch that is
     * off by default for apps the platform does not treat as alarm or calling
     * apps; without it the call is only a heads-up notification.
     */
    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return true
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return manager.canUseFullScreenIntent()
    }

    companion object {
        private const val CHANNEL = "com.subhwarrior.app/fajr_call"

        /**
         * flutter_local_notifications puts the payload under this extra.
         */
        private const val PAYLOAD_EXTRA = "payload"

        /**
         * Must match FajrCallService.payload on the Dart side.
         */
        private const val FAJR_CALL_PAYLOAD = "fajr_call"
    }
}
