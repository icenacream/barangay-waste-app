import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

Future<void> init() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila'));

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await _plugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) {},
  );

  // Request permission on Android 13+

}

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'brgywaste_channel',
      'QCEcoTrack Notifications',
      channelDescription: 'Waste collection notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  // Schedule notification for a specific date and time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'brgywaste_scheduled',
      'QCEcoTrack Scheduled Notifications',
      channelDescription: 'Scheduled waste collection reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // Schedule collection reminder
  // This schedules a notification the day before at 8:00 PM
  // and on the day itself at 6:00 AM
  Future<void> scheduleCollectionReminder({
    required DateTime collectionDate,
    required String barangay,
    required String time,
  }) async {
    await cancelNotification(1);
    await cancelNotification(2);

    final now = DateTime.now();

    // Night before at 8:00 PM
    final dayBefore = DateTime(
      collectionDate.year,
      collectionDate.month,
      collectionDate.day - 1,
      20,
      0,
    );

    if (dayBefore.isAfter(now)) {
      await scheduleNotification(
        id: 1,
        title: '🗑️ Garbage Collection Tomorrow!',
        body:
            'Reminder: Waste collection for $barangay is scheduled tomorrow at $time. Please prepare your garbage tonight.',
        scheduledDate: dayBefore,
      );
    }

    // Morning of collection at 6:00 AM
    final morningOf = DateTime(
      collectionDate.year,
      collectionDate.month,
      collectionDate.day,
      6,
      0,
    );

    if (morningOf.isAfter(now)) {
      await scheduleNotification(
        id: 2,
        title: '🗑️ Garbage Collection Today!',
        body:
            'Waste collection for $barangay is today at $time. Please bring out your garbage now.',
        scheduledDate: morningOf,
      );
    }
  }
}