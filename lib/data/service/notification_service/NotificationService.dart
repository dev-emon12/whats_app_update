import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:whats_app/binding/enum.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/utiles/const/keys.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // channel for chat and call
  static const String _channelId = 'comms_channel_id';
  static const String _channelName = 'WhatsApp Alerts';
  static const String _channelDesc = 'Messages and calls';

  // call notification id
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

  // Safe to call from background isolate
  Future<void> ensureInitialized() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // ✅ Create only ONE channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );
    await androidPlugin?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  // request for permission
  Future<void> _requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
  }

  // local notification handeler
  Future<void> _onNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    final actionId = response.actionId;

    if (payload == null || payload.isEmpty) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = (data['type'] ?? 'chat').toString();

    // ✅ REPLY (chat)
    if (actionId == 'REPLY_ACTION') {
      final replyText = (response.input ?? '').trim();
      if (replyText.isEmpty) return;

      final otherUserId = (data['otherUserId'] ?? data['senderId'] ?? '')
          .toString()
          .trim();
      if (otherUserId.isEmpty) return;

      // ✅ avoid crash: make sure "me" is loaded before sending
      await Messagerepository.initMe();

      final otherUser = await _fetchUserModel(otherUserId);
      if (otherUser == null) return;

      await Messagerepository.sendMessage(
        otherUser,
        replyText,
        MessageType.text,
      );

      return;
    }

    // ✅ CALL actions/tap
    if (type == 'call') {
      final callDocId = (data['callDocId'] ?? '').toString();

      if (actionId == 'DECLINE_CALL') {
        await _plugin.cancel(_callNotifId);

        // reject zego invite
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

      if (actionId == 'ACCEPT_CALL') {
        await _plugin.cancel(_callNotifId);

        try {
          final ok = await ZegoUIKitPrebuiltCallInvitationService().accept();
          if (ok) {
            ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
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

      // normal tap (no buttons)
      try {
        ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
      } catch (_) {}
      return;
    }

    // ✅ normal chat tap
    await _openChatFromData(data);
  }

  //show chat notification
  Future<void> showChatNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      styleInformation: const BigTextStyleInformation(''),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'REPLY_ACTION',
          'Reply',
          showsUserInterface: true,
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(label: 'Type your reply...'),
          ],
        ),
      ],
    );

    final payload = jsonEncode(data);

    final id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // show call notification
  Future<void> showIncomingCallNotification({
    required String callerName,
    required Map<String, dynamic> data,
  }) async {
    await ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction('ACCEPT_CALL', 'Accept'),
        AndroidNotificationAction('DECLINE_CALL', 'Decline'),
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

  //fcm for forgroung
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final type = (message.data['type'] ?? '').toString();

      // call
      if (type == 'call') {
        await showIncomingCallNotification(
          callerName: (message.data['callerName'] ?? 'Incoming call')
              .toString(),
          data: message.data,
        );
        return;
      }

      // chat
      final title =
          message.data['senderName']?.toString() ??
          message.notification?.title ??
          'Message';

      final body =
          message.data['message']?.toString() ??
          message.notification?.body ??
          'New message';

      await showChatNotification(title: title, body: body, data: message.data);
    });
  }

  //tap from backgroung
  void _listenNotificationTapBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.data.isEmpty) return;

      final type = (message.data['type'] ?? 'chat').toString();
      if (type == 'call') {
        try {
          ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
        } catch (_) {}
        return;
      }

      await _openChatFromData(message.data);
    });
  }

  // tap from terminate
  Future<void> _handleTerminatedTap() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial == null || initial.data.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 300));

    final type = (initial.data['type'] ?? 'chat').toString();
    if (type == 'call') {
      try {
        ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
      } catch (_) {}
      return;
    }

    await _openChatFromData(initial.data);
  }

  //open chat
  Future<void> _openChatFromData(Map<String, dynamic> data) async {
    final otherUserId =
        (data['otherUserId'] ?? data['senderId'] ?? data['chatUserId'] ?? '')
            .toString()
            .trim();

    if (otherUserId.isEmpty) return;

    final otherUser = await _fetchUserModel(otherUserId);
    if (otherUser == null) return;

    Get.to(() => const ChattingScreen(), arguments: otherUser);
  }

  // user model
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
