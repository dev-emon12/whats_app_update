import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'chat_channel_id';
  static const String _channelName = 'Chat Messages';
  static const String _channelDesc = 'Notifications for chat messages';

  bool _initialized = false;

  Future<void> initLocalNotifications() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(" Notification tapped payload: ${response.payload}");

        // If you want to open chat on tap:
        // if (response.payload != null && response.payload!.isNotEmpty) {
        //   final data = jsonDecode(response.payload!);
        //   // Get.to(() => ChattingScreen(), arguments: userModel);
        // }
      },
    );

    // Create channel (Android)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<void> requestAndroidPermissionIfNeeded() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showChatNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await initLocalNotifications();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
    );

    final details = NotificationDetails(android: androidDetails);

    final payload = data == null ? '' : jsonEncode(data);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void initFcmListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(" onMessage CALLED");
      debugPrint(" data: ${message.data}");
      debugPrint(
        " notif: ${message.notification?.title} | ${message.notification?.body}",
      );

      //  IMPORTANT: for Firebase Console notification messages, data is {}
      final title =
          message.notification?.title ??
          message.data['senderName'] ??
          'Message';
      final body =
          message.notification?.body ??
          message.data['message'] ??
          'New message';

      await showChatNotification(
        title: title,
        body: body,
        data: message.data.isEmpty ? null : message.data,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📩 Opened from notification: ${message.data}");
    });
  }
}
