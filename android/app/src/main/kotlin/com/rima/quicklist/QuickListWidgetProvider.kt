package com.rimaoli.quicklist

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.util.Log
import android.view.View
import android.widget.RemoteViews

class QuickListWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "QuickListWidget"
        private const val MAX_TASKS = 4
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_layout)

                // Click on widget container opens the app
                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val openAppPendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    openAppIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, openAppPendingIntent)

                // FAB click opens add task screen directly
                val addTaskIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("open_add_task", true)
                }
                val addTaskPendingIntent = PendingIntent.getActivity(
                    context,
                    1,
                    addTaskIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.fab_add_task, addTaskPendingIntent)

                // Get data from shared preferences
                val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                val taskCount = prefs.getInt("task_count", 0).coerceIn(0, MAX_TASKS)

                // Row, title, checkbox, deadline IDs
                val rowIds = intArrayOf(
                    R.id.task_row_1, R.id.task_row_2, R.id.task_row_3, R.id.task_row_4
                )
                val titleIds = intArrayOf(
                    R.id.task_title_1, R.id.task_title_2, R.id.task_title_3, R.id.task_title_4
                )
                val checkboxIds = intArrayOf(
                    R.id.task_checkbox_1, R.id.task_checkbox_2, R.id.task_checkbox_3, R.id.task_checkbox_4
                )
                val deadlineIds = intArrayOf(
                    R.id.task_deadline_1, R.id.task_deadline_2,
                    R.id.task_deadline_3, R.id.task_deadline_4
                )

                var visibleCount = 0
                for (i in 0 until MAX_TASKS) {
                    if (i < taskCount) {
                        val title = prefs.getString("task_title_$i", "") ?: ""
                        if (title.isNotEmpty()) {
                            views.setViewVisibility(rowIds[i], View.VISIBLE)
                            views.setTextViewText(titleIds[i], title)

                            // Checkbox: completed or not
                            val isCompleted = prefs.getBoolean("task_completed_$i", false)
                            if (isCompleted) {
                                views.setImageViewResource(checkboxIds[i], R.drawable.checkbox_checked)
                                views.setTextColor(titleIds[i], 0xFF8E8E93.toInt())
                            } else {
                                views.setImageViewResource(checkboxIds[i], R.drawable.checkbox_unchecked)
                                views.setTextColor(titleIds[i], 0xFF1C1C1E.toInt())
                            }

                            // Deadline label
                            val deadline = prefs.getString("task_deadline_$i", "") ?: ""
                            if (deadline.isNotEmpty()) {
                                views.setTextViewText(deadlineIds[i], deadline)
                                views.setViewVisibility(deadlineIds[i], View.VISIBLE)
                                val isOverdue = prefs.getBoolean("task_overdue_$i", false)
                                if (isOverdue) {
                                    views.setTextColor(deadlineIds[i], 0xFFFF3B30.toInt())
                                } else {
                                    views.setTextColor(deadlineIds[i], 0xFF8E8E93.toInt())
                                }
                            } else {
                                views.setViewVisibility(deadlineIds[i], View.GONE)
                            }

                            visibleCount++
                        } else {
                            views.setViewVisibility(rowIds[i], View.GONE)
                        }
                    } else {
                        views.setViewVisibility(rowIds[i], View.GONE)
                    }
                }

                // Show empty state if no tasks
                if (visibleCount == 0) {
                    views.setViewVisibility(R.id.empty_state, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.empty_state, View.GONE)
                }

                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget $widgetId", e)
            }
        }
    }
}
