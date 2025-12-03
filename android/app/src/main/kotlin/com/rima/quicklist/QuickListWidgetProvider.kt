package com.rima.quicklist

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class QuickListWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Create intent to open the app
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                // Get data from shared preferences
                val widgetData = HomeWidgetPlugin.getData(context)
                val totalTasks = widgetData.getInt("total_tasks", 0)
                val completedTasks = widgetData.getInt("completed_tasks", 0)
                val activeTasks = widgetData.getInt("active_tasks", 0)
                val nextTaskTitle = widgetData.getString("next_task_title", "No tasks")

                // Update widget views
                setTextViewText(R.id.total_tasks, totalTasks.toString())
                setTextViewText(R.id.completed_tasks, completedTasks.toString())
                setTextViewText(R.id.active_tasks, activeTasks.toString())
                setTextViewText(R.id.next_task_title, nextTaskTitle)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
