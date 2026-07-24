package com.subhwarrior.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Populates the Fajr home-screen widget from the `home_widget`-managed
 * SharedPreferences that FajrWidgetService (Dart side) writes to. Shows a
 * placeholder instead of blank/crashing views when nothing has been saved
 * yet (fresh install, widget added before the app was ever opened).
 */
class FajrWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.fajr_widget)

            val title = widgetData.getString("fajr_widget_title", null)
            val time = widgetData.getString("fajr_widget_time", null)
            val countdown = widgetData.getString("fajr_widget_countdown", null)
            val progress = widgetData.getString("fajr_widget_progress", null)

            if (title == null || time == null || countdown == null || progress == null) {
                views.setViewVisibility(R.id.fajr_widget_content, View.GONE)
                views.setViewVisibility(R.id.fajr_widget_placeholder, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.fajr_widget_content, View.VISIBLE)
                views.setViewVisibility(R.id.fajr_widget_placeholder, View.GONE)
                views.setTextViewText(R.id.fajr_widget_title, title)
                views.setTextViewText(R.id.fajr_widget_time, time)
                views.setTextViewText(R.id.fajr_widget_countdown, countdown)
                views.setProgressBar(
                    R.id.fajr_widget_progress_bar,
                    100,
                    progress.toIntOrNull() ?: 0,
                    false
                )
            }

            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.fajr_widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
