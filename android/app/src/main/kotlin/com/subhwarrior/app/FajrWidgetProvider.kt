package com.subhwarrior.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Fajr widget: header (icon/title/NOW badge), Today/Tomorrow/Next-Fajr-In
 * row, Sunrise/Dhuhr/Asr/Maghrib/Isha mini-row, progress bar. A fixed
 * layout — no runtime size detection (that approach reacted to launcher
 * scroll/reflow events and could flip layouts mid-scroll). Resizable
 * horizontally only; the content height is fixed.
 */
class FajrWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.fajr_widget_full)

            if (bindPlaceholderOrContent(views, widgetData)) {
                bindCommon(views, widgetData)
                views.setTextViewText(
                    R.id.fajr_widget_today_time,
                    widgetData.getString("fajr_widget_time", "")
                )
                views.setTextViewText(
                    R.id.fajr_widget_tomorrow_time,
                    widgetData.getString("fajr_widget_tomorrow_time", "")
                )
                // Fallback text (e.g. "Unknown" when there's no next-Fajr
                // time to count down to) — overwritten below by the real
                // ticking Chronometer whenever we have a target to count
                // down to.
                views.setTextViewText(
                    R.id.fajr_widget_countdown,
                    widgetData.getString("fajr_widget_countdown", "")
                )
                bindLiveCountdown(context, views, widgetData)
                views.setTextViewText(
                    R.id.fajr_widget_sunrise_value,
                    widgetData.getString("fajr_widget_sunrise", "")
                )
                views.setTextViewText(
                    R.id.fajr_widget_dhuhr_value,
                    widgetData.getString("fajr_widget_dhuhr", "")
                )
                views.setTextViewText(
                    R.id.fajr_widget_asr_value,
                    widgetData.getString("fajr_widget_asr", "")
                )
                views.setTextViewText(
                    R.id.fajr_widget_maghrib_value,
                    widgetData.getString("fajr_widget_maghrib", "")
                )
                views.setTextViewText(
                    R.id.fajr_widget_isha_value,
                    widgetData.getString("fajr_widget_isha", "")
                )
            }

            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.fajr_widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun hasCoreData(widgetData: SharedPreferences): Boolean {
        return widgetData.getString("fajr_widget_title", null) != null &&
            widgetData.getString("fajr_widget_time", null) != null &&
            widgetData.getString("fajr_widget_countdown", null) != null &&
            widgetData.getString("fajr_widget_progress", null) != null
    }

    /** Toggles the placeholder vs content group. Returns whether real data exists. */
    private fun bindPlaceholderOrContent(views: RemoteViews, widgetData: SharedPreferences): Boolean {
        val hasData = hasCoreData(widgetData)
        views.setViewVisibility(
            R.id.fajr_widget_content,
            if (hasData) View.VISIBLE else View.GONE
        )
        views.setViewVisibility(
            R.id.fajr_widget_placeholder,
            if (hasData) View.GONE else View.VISIBLE
        )
        return hasData
    }

    /** Binds the title, NOW badge, and progress bar. */
    private fun bindCommon(views: RemoteViews, widgetData: SharedPreferences) {
        views.setTextViewText(
            R.id.fajr_widget_title,
            widgetData.getString("fajr_widget_title", "")
        )
        val isWithinWindow = widgetData.getString("fajr_widget_is_within_window", "false")
        views.setViewVisibility(
            R.id.fajr_widget_now_badge,
            if (isWithinWindow == "true") View.VISIBLE else View.GONE
        )
        val progress = widgetData.getString("fajr_widget_progress", null)?.toIntOrNull() ?: 0
        views.setProgressBar(R.id.fajr_widget_progress_bar, 100, progress, false)
    }

    /**
     * Starts the countdown TextView (an `android.widget.Chronometer` in the
     * layout) ticking down live, once per second, entirely on-device — the
     * launcher process runs the tick loop itself, no app wake-up needed.
     * This is the only way to get a genuinely live-updating number in a
     * home-screen widget; our own background refresh (every 30 min) is far
     * too coarse to redraw a seconds digit convincingly.
     *
     * [RemoteViews.setChronometer]'s `base` must be in
     * [SystemClock.elapsedRealtime] terms, not wall-clock time — Dart has no
     * access to that clock, so it hands us the plain target epoch
     * (`System.currentTimeMillis()`-compatible) instead and we convert here,
     * at bind time.
     *
     * The 4th parameter of [RemoteViews.setChronometer] is `started`
     * (whether the Chronometer should be running), **not** "count down" —
     * a genuinely easy mix-up given the two overloads' names. Counting
     * down requires the separate [RemoteViews.setChronometerCountDown]
     * call below; without it the Chronometer silently runs in its default
     * count-*up* mode and displays `now - base` with no negation, which
     * — since `base` is in the future — renders as a *negative* number
     * that shrinks toward zero and then flips positive once the target
     * passes, instead of a positive countdown that reaches zero.
     */
    /**
     * Wakes the widget up the moment its countdown target passes.
     *
     * The Chronometer ticks entirely inside the launcher, so nothing tells us
     * when it reaches zero. Until something re-binds the widget it keeps
     * counting straight past zero into negative numbers — and the only thing
     * that re-binds it is a Dart-side refresh, which needs the app process,
     * a background-fetch delivery and (until recently) the network. Any of
     * those missing left a permanently negative countdown on the home screen.
     *
     * This asks AlarmManager for a single broadcast a second after the
     * target, so [onUpdate] runs and the branch above swaps the stale
     * countdown for its placeholder. Inexact on purpose: this only tidies the
     * display, and an exact alarm here would compete with the Fajr call's.
     */
    /**
     * Shows the "unknown" placeholder in place of the countdown.
     *
     * The Chronometer is stopped first: a running one rewrites its own text
     * every second, so setting text on a live Chronometer does nothing. The
     * last *countdown value* is deliberately not reused here — a frozen number
     * looks like a live one, which is how a stale widget went unnoticed.
     */
    private fun bindCountdownPlaceholder(
        views: RemoteViews,
        widgetData: SharedPreferences
    ) {
        views.setChronometer(
            R.id.fajr_widget_countdown,
            SystemClock.elapsedRealtime(),
            null,
            false
        )
        views.setTextViewText(
            R.id.fajr_widget_countdown,
            widgetData.getString("fajr_widget_countdown_unknown", "--:--")
        )
    }

    private fun scheduleBoundaryRebind(context: Context, targetEpochMs: Long) {
        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

        val intent = Intent(context, FajrWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, FajrWidgetProvider::class.java))
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REBIND_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.set(
            AlarmManager.RTC,
            targetEpochMs + 1_000L,
            pendingIntent
        )
    }

    private fun bindLiveCountdown(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences
    ) {
        // Two targets are stored: the next Fajr, and the one after it. Once
        // the first has passed the widget rolls on to the second by itself,
        // rather than waiting for a Dart refresh that may not come while the
        // app stays closed — which is what left the countdown negative, and
        // then frozen on its last value.
        val targetEpochMs = listOfNotNull(
            widgetData.getString("fajr_widget_next_fajr_epoch_ms", null)?.toLongOrNull(),
            widgetData.getString("fajr_widget_following_fajr_epoch_ms", null)
                ?.toLongOrNull()
        ).firstOrNull { it - System.currentTimeMillis() > 0 }
            ?: run {
                bindCountdownPlaceholder(views, widgetData)
                return
            }

        val msUntilTarget = targetEpochMs - System.currentTimeMillis()
        val base = SystemClock.elapsedRealtime() + msUntilTarget
        views.setChronometer(R.id.fajr_widget_countdown, base, null, true)
        views.setChronometerCountDown(R.id.fajr_widget_countdown, true)

        // Come back when it hits zero, so a missed refresh cannot leave the
        // countdown ticking into negative numbers.
        scheduleBoundaryRebind(context, targetEpochMs)
    }

    private companion object {
        const val REBIND_REQUEST_CODE = 20260929
    }
}