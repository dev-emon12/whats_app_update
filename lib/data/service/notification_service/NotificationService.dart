import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // chat channel
  static const String _channelId = 'chat_channel_id';
  static const String _channelName = 'Chat Messages';
  static const String _channelDesc = 'Notifications for chat messages';

  //call channel
  static const String _callChannelId = 'call_channel_id';
  static const String _callChannelName = 'Calls';
  static const String _callChannelDesc = 'Incoming call notifications';
  static const int _callNotifId = 9001;

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> init({required GlobalKey<NavigatorState> navigatorKey}) async {
    _navigatorKey = navigatorKey;

    await ensureInitialized();
    await _requestPermissions();

    _listenForeground();
    _listenNotificationTapBackground();
    await _handleTerminatedTap();
  }

  /// Safe to call from background isolate

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        final actionId = response.actionId;
        if (payload == null || payload.isEmpty) return;

        Map<String, dynamic> data;
        try {
          data = jsonDecode(payload) as Map<String, dynamic>;
        } catch (_) {
          return;
        }

        final type = (data['type'] ?? '').toString();

        // ✅ CALL notification tap/actions
        if (type == 'call') {
          // Optional: update Firestore call status
          final callDocId = (data['callDocId'] ?? '').toString();

          // DECLINE
          if (actionId == 'DECLINE_CALL') {
            await _plugin.cancel(_callNotifId);

            // ✅ Reject Zego invitation
            // (works when invitation exists after init) :contentReference[oaicite:1]{index=1}
            try {
              await ZegoUIKitPrebuiltCallInvitationService().reject();
            } catch (_) {}

            if (callDocId.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callDocId)
                  .update({
                    'status': 'ended',
                    'endedAt': DateTime.now().millisecondsSinceEpoch,
                    'endedAtText': DateTime.now().toString(),
                  })
                  .catchError((_) {});
            }
            return;
          }

          // ACCEPT
          if (actionId == 'ACCEPT_CALL') {
            await _plugin.cancel(_callNotifId);

            // ✅ Accept Zego invitation :contentReference[oaicite:2]{index=2}
            try {
              final ok = await ZegoUIKitPrebuiltCallInvitationService()
                  .accept();
              if (ok) {
                // For offline/late navigation scenarios, Zego provides this helper :contentReference[oaicite:3]{index=3}
                ZegoUIKitPrebuiltCallInvitationService()
                    .enterAcceptedOfflineCall();
              }
            } catch (_) {}

            if (callDocId.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callDocId)
                  .update({
                    'status': 'accepted',
                    'connectedAt': DateTime.now().millisecondsSinceEpoch,
                  })
                  .catchError((_) {});
            }
            return;
          }

          // Normal tap on call notification (no button)
          // Just bring app foreground; Zego will show its call UI if invite is active.
          try {
            ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
          } catch (_) {}
          return;
        }

        // ✅ CHAT notification tap
        await _openChatFromData(data);
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // chat channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );

    await androidPlugin?.createNotificationChannel(androidChannel);

    //call channel
    const callChannel = AndroidNotificationChannel(
      _callChannelId,
      _callChannelName,
      description: _callChannelDesc,
      importance: Importance.max,
    );
    await androidPlugin?.createNotificationChannel(callChannel);

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission();

    // Android 13+ permission for local notifications
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
    await ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
    );

    final details = NotificationDetails(android: androidDetails);

    // IMPORTANT: include "otherUserId" or "senderId" in data so we can open correct chat
    final payload = data == null ? '' : jsonEncode(data);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showIncomingCallNotification({
    required String callerName,
    required Map<String, dynamic> data,
  }) async {
    await ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      _callChannelId,
      _callChannelName,
      channelDescription: _callChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('ACCEPT_CALL', 'Accept'),
        const AndroidNotificationAction('DECLINE_CALL', 'Decline'),
      ],
    );

    await _plugin.show(
      _callNotifId,
      'Incoming ${data["callType"] ?? "call"}',
      callerName,
      NotificationDetails(android: androidDetails),
      payload: jsonEncode(data),
    );
  }

  // FOREGROUND
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final type = (message.data['type'] ?? '').toString();

      // ✅ CALL push
      if (type == 'call') {
        await showIncomingCallNotification(
          callerName: (message.data['callerName'] ?? 'Incoming call')
              .toString(),
          data: message.data,
        );
        return;
      }

      // ✅ CHAT push
      final title =
          message.notification?.title ??
          message.data['senderName']?.toString() ??
          'Message';

      final body =
          message.notification?.body ??
          message.data['message']?.toString() ??
          'New message';

      await showChatNotification(
        title: title,
        body: body,
        data: message.data.isEmpty ? null : message.data,
      );
    });
  }

  // BACKGROUND tap (app in background)
  void _listenNotificationTapBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.data.isNotEmpty) {
        await _openChatFromData(message.data);
      }
    });
  }

  // TERMINATED tap (app fully closed)
  Future<void> _handleTerminatedTap() async {
    final RemoteMessage? initial = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initial != null && initial.data.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 300));
      await _openChatFromData(initial.data);
    }
  }

  Future<void> _openChatFromData(Map<String, dynamic> data) async {
    final otherUserId =
        (data['otherUserId'] ?? data['senderId'] ?? data['chatUserId'] ?? '')
            .toString()
            .trim();

    if (otherUserId.isEmpty) return;

    final otherUser = await _fetchUserModel(otherUserId);
    if (otherUser == null) return;

    Get.to(() => ChattingScreen(), arguments: otherUser);
  }

  Future<UserModel?> _fetchUserModel(String uid) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .doc(uid)
          .get();

      if (!snap.exists) return null;

      return UserModel.fromSnapshot(snap);
    } catch (_) {
      return null;
    }
  }
}
