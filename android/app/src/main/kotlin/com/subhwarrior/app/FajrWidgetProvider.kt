package com.subhwarrior.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Populates the Fajr home-screen widget from the `home_widget`-managed
 * SharedPreferences that FajrWidgetService (Dart side) writes to. Shows a
 * placeholder instead of blank/crashing views when nothing has been saved
 * yet (fresh install, widget added before the app was ever opened).
 *
 * Responsive: picks between a compact layout (title/time/countdown/
 * progress) and a full layout (adds the Today/Tomorrow/Next-Fajr-In row
 * and the Sunrise/Dhuhr/Asr/Maghrib/Isha mini-row) based on the widget's
 * actual current size, re-evaluated on every resize via
 * [onAppWidgetOptionsChanged].
 */
class FajrWidgetProvider : HomeWidgetProvider() {

    companion object {
        private const val FULL_MIN_WIDTH_DP = 250
        private const val FULL_MIN_HEIGHT_DP = 110
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            updateOne(context, appWidgetManager, widgetId, widgetData)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateOne(context, appWidgetManager, appWidgetId, HomeWidgetPlugin.getData(context))
    }

    private fun updateOne(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences
    ) {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        val useFull = width >= FULL_MIN_WIDTH_DP && height >= FULL_MIN_HEIGHT_DP

        val views = if (useFull) {
            buildFullViews(context, widgetData)
        } else {
            buildCompactViews(context, widgetData)
        }

        val pendingIntent =
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.fajr_widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun hasCoreData(widgetData: SharedPreferences): Boolean {
        return widgetData.getString("fajr_widget_title", null) != null &&
            widgetData.getString("fajr_widget_time", null) != null &&
            widgetData.getString("fajr_widget_countdown", null) != null &&
            widgetData.getString("fajr_widget_progress", null) != null
    }

    private fun bindPlaceholderOrContent(
        views: RemoteViews,
        widgetData: SharedPreferences
    ): Boolean {
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

    private fun buildCompactViews(
        context: Context,
        widgetData: SharedPreferences
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.fajr_widget_compact)
        if (!bindPlaceholderOrContent(views, widgetData)) return views

        bindCommon(views, widgetData)
        views.setTextViewText(
            R.id.fajr_widget_time,
            widgetData.getString("fajr_widget_time", "")
        )
        views.setTextViewText(
            R.id.fajr_widget_countdown,
            widgetData.getString("fajr_widget_countdown", "")
        )
        return views
    }

    private fun buildFullViews(
        context: Context,
        widgetData: SharedPreferences
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.fajr_widget_full)
        if (!bindPlaceholderOrContent(views, widgetData)) return views

        bindCommon(views, widgetData)
        views.setTextViewText(
            R.id.fajr_widget_today_time,
            widgetData.getString("fajr_widget_time", "")
        )
        views.setTextViewText(
            R.id.fajr_widget_tomorrow_time,
            widgetData.getString("fajr_widget_tomorrow_time", "")
        )
        views.setTextViewText(
            R.id.fajr_widget_countdown,
            widgetData.getString("fajr_widget_countdown", "")
        )
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
        return views
    }
}
