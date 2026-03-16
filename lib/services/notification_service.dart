import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);

    // Request permission on Android 13+
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showBudgetExceededNotification(
    double totalExpense, [
    double limit = 1000,
  ]) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications when monthly budget limit is exceeded',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      0,
      'Budget Limit Exceeded!',
      'Your monthly expenses have reached \u{20B9}${totalExpense.toStringAsFixed(0)}. '
          'This exceeds your \u{20B9}${limit.toStringAsFixed(0)} budget limit.',
      notificationDetails,
    );
  }
}
