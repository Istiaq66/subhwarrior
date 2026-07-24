package com.subhwarrior.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Compact Fajr widget: header (icon/title/NOW badge), today's Fajr time,
 * countdown, progress bar. A separate, always-available widget entry in
 * the picker — pick [FajrWidgetProvider] instead for the full card. Fixed
 * layout, no runtime size detection (see [FajrWidgetProvider]'s doc comment
 * for why).
 */
class FajrCompactWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.fajr_widget_compact)

            if (FajrWidgetBinding.bindPlaceholderOrContent(views, widgetData)) {
                FajrWidgetBinding.bindCommon(views, widgetData)
                views.setTextViewText(
                    R.id.fajr_widget_time,
                    widgetData.getString("fajr_widget_time", "")
                )
                views.setTextViewText(
                    R.id.fajr_widget_countdown,
                    widgetData.getString("fajr_widget_countdown", "")
                )
            }

            FajrWidgetBinding.bindTapToOpen(context, views)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}