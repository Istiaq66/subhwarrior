package com.subhwarrior.app

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/**
 * Shared binding logic for the two fixed Fajr widget providers
 * ([FajrWidgetProvider] — full card, [FajrCompactWidgetProvider] — compact).
 * Both read the same `home_widget`-managed SharedPreferences that
 * FajrWidgetService (Dart side) writes to; they differ only in which
 * layout/view-ids they bind.
 */
object FajrWidgetBinding {
    private fun hasCoreData(widgetData: SharedPreferences): Boolean {
        return widgetData.getString("fajr_widget_title", null) != null &&
            widgetData.getString("fajr_widget_time", null) != null &&
            widgetData.getString("fajr_widget_countdown", null) != null &&
            widgetData.getString("fajr_widget_progress", null) != null
    }

    /** Toggles the placeholder vs content group. Returns whether real data exists. */
    fun bindPlaceholderOrContent(views: RemoteViews, widgetData: SharedPreferences): Boolean {
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

    /** Binds the title, NOW badge, and progress bar shared by both layouts. */
    fun bindCommon(views: RemoteViews, widgetData: SharedPreferences) {
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

    fun bindTapToOpen(context: Context, views: RemoteViews) {
        val pendingIntent =
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.fajr_widget_root, pendingIntent)
    }
}