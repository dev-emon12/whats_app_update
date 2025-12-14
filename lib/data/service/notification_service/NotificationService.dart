import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings);
  }

  /// Call once from main() AFTER initLocalNotifications()
  void initFcmListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //  if you sent data
      final data = message.data;

      //  if you sent notification payload
      final notif = message.notification;

      final title =
          data['senderName']?.toString() ?? notif?.title ?? 'New message';

      final body = data['message']?.toString() ?? notif?.body ?? '';

      showChatNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
      );
    });
  }

  Future<void> showChatNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Messages',
      channelDescription: 'Notifications for chat messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details, payload: payload);
  }
}
