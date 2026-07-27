package com.subhwarrior.app

import android.appwidget.AppWidgetManager
import android.content.Context
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
                bindLiveCountdown(views, widgetData)
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
    private fun bindLiveCountdown(views: RemoteViews, widgetData: SharedPreferences) {
        val targetEpochMs =
            widgetData.getString("fajr_widget_next_fajr_epoch_ms", null)?.toLongOrNull()
                ?: return
        val msUntilTarget = targetEpochMs - System.currentTimeMillis()
        if (msUntilTarget <= 0) return

        val base = SystemClock.elapsedRealtime() + msUntilTarget
        views.setChronometer(R.id.fajr_widget_countdown, base, null, true)
        views.setChronometerCountDown(R.id.fajr_widget_countdown, true)
    }
}