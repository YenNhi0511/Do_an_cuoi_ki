import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? priority,
  }) async {
    // Xác định importance và priority dựa trên loại notification
    final importance = priority == 'high' ? Importance.max : Importance.high;
    final notificationPriority =
        priority == 'high' ? Priority.max : Priority.high;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel_id',
      'Công việc',
      channelDescription: 'Thông báo công việc hằng ngày',
      importance: importance,
      priority: notificationPriority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  // Hiển thị notification cho task quá hạn
  Future<void> showOverdueNotification(
      String taskTitle, int daysOverdue) async {
    await showNotification(
      title: '⚠️ Công việc quá hạn!',
      body: '"$taskTitle" đã quá hạn $daysOverdue ngày',
      priority: 'high',
    );
  }

  // Hiển thị notification cho task sắp hết hạn
  Future<void> showDueSoonNotification(String taskTitle, int daysLeft) async {
    await showNotification(
      title: '⏰ Sắp hết hạn!',
      body: '"$taskTitle" còn $daysLeft ngày',
      priority: daysLeft <= 1 ? 'high' : 'medium',
    );
  }

  // Hiển thị notification cho task khẩn cấp
  Future<void> showUrgentNotification(String taskTitle) async {
    await showNotification(
      title: '🚨 Công việc khẩn cấp!',
      body: '"$taskTitle" cần xử lý ngay',
      priority: 'high',
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel_id',
          'Lịch công việc',
          channelDescription: 'Thông báo nhắc nhở công việc',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,

      // === SỬA LỖI ===
      // Thêm tham số bắt buộc này cho iOS
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      // ===============
    );
  }
}
