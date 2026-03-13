import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 本地通知服务
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  bool _isInitialized = false;
  bool get isWeb => kIsWeb;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Web 平台不初始化本地通知
    if (isWeb) {
      _isInitialized = true;
      return;
    }

    // 初始化时区数据
    tz_data.initializeTimeZones();

    // Android 配置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 配置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    // 处理通知点击
    print('Notification clicked: ${response.payload}');
  }

  /// 请求权限
  Future<bool> requestPermissions() async {
    if (isWeb) return true;
    
    if (Platform.isIOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }
    
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // Android 13+ 需要请求通知权限
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true;
  }

  /// 安排每日提醒
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required String time, // HH:mm 格式
    String? payload,
  }) async {
    if (isWeb) return; // Web 不支持本地通知
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // 如果今天的时间已过，安排到明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'supplement_reminders',
          '补剂提醒',
          channelDescription: '提醒您按时服用补剂',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// 取消特定提醒
  Future<void> cancelReminder(int id) async {
    if (isWeb) return;
    await _notifications.cancel(id);
  }

  /// 取消所有提醒
  Future<void> cancelAllReminders() async {
    if (isWeb) return;
    await _notifications.cancelAll();
  }

  /// 显示即时通知（用于测试或漏服提醒）
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (isWeb) return;
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'supplement_alerts',
          '补剂通知',
          channelDescription: '补剂相关通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// 检查是否已安排提醒
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
