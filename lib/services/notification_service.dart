import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import '../models/task.dart';

/// Handles all local notification scheduling, cancellation, and initialization.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification plugin and timezone data.
  /// Must be called once before any scheduling.
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_getLocalTimezoneName()));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);
    _isInitialized = true;
  }

  /// Request notification permission (required on Android 13+).
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Schedule a notification at the task's due time.
  /// Does nothing if the task has no due date or the due date is in the past.
  Future<void> scheduleTaskNotification(Task task) async {
    if (task.dueDate == null) return;
    if (task.isCompleted) return;

    final now = DateTime.now();
    if (task.dueDate!.isBefore(now)) return;

    // Generate a stable integer notification ID from the task's string ID
    final notificationId = task.id.hashCode;

    // Cancel any existing notification for this task before scheduling a new one
    await _plugin.cancel(notificationId);

    final scheduledDate = tz.TZDateTime.from(task.dueDate!, tz.local);

    // Build the notification details
    const androidDetails = AndroidNotificationDetails(
      'todo_task_reminders', // channel ID
      'Task Reminders', // channel name
      channelDescription: 'Notifications for task due time reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true, // uses default notification sound
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      channelShowBadge: true,
      autoCancel: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      notificationId,
      '⏰ ${task.title}',
      'Task is due now! • ${task.category} • ${task.priority[0].toUpperCase()}${task.priority.substring(1)} priority',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // one-shot, not recurring
    );
  }

  /// Cancel the notification for a specific task.
  Future<void> cancelTaskNotification(String taskId) async {
    await _plugin.cancel(taskId.hashCode);
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Schedule notifications for all incomplete tasks with future due dates.
  /// Useful after app restart to re-register alarms.
  Future<void> rescheduleAll(List<Task> tasks) async {
    for (final task in tasks) {
      if (!task.isCompleted && task.dueDate != null) {
        await scheduleTaskNotification(task);
      }
    }
  }

  /// Get the local timezone name. Falls back to UTC if unavailable.
  String _getLocalTimezoneName() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      // Try to find a matching timezone
      for (final location in tz.timeZoneDatabase.locations.values) {
        final now = tz.TZDateTime.now(location);
        if (now.timeZoneOffset == offset) {
          return location.name;
        }
      }
    } catch (_) {}
    return 'UTC';
  }
}
