package com.subhwarrior.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Full-card Fajr widget: header (icon/title/NOW badge), Today/Tomorrow/
 * Next-Fajr-In row, Sunrise/Dhuhr/Asr/Maghrib/Isha mini-row, progress bar.
 * A fixed layout — no runtime size detection (that approach reacted to
 * launcher scroll/reflow events and could flip the layout mid-scroll).
 * Users who want the smaller layout pick [FajrCompactWidgetProvider]
 * instead from the widget list, matching how Sadiq ships separate
 * Vertical/Horizontal/Calendar widgets rather than one adaptive widget.
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

            if (FajrWidgetBinding.bindPlaceholderOrContent(views, widgetData)) {
                FajrWidgetBinding.bindCommon(views, widgetData)
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
            }

            FajrWidgetBinding.bindTapToOpen(context, views)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}