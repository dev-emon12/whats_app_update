import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:whats_app/data/service/notification_service/NotificationService.dart';
import 'package:whats_app/data/service/zego_service.dart';
import 'package:whats_app/firebase_options.dart';
import 'package:whats_app/my_apps.dart';
import 'data/repository/authentication_repo/AuthenticationRepo.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background: ${message.data}');
}

final navigatorKey = GlobalKey<NavigatorState>();

StreamSubscription<User?>? _authSub;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthenticationRepository(), permanent: true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.instance.initLocalNotifications();
  NotificationService.instance.initFcmListeners();
  await NotificationService.instance.requestAndroidPermissionIfNeeded();

  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user == null) {
      ZegoService.instance.uninit();
      return;
    }

    final safeId = user.uid;
    final safeName = (user.displayName ?? user.phoneNumber ?? '').trim();

    await ZegoService.instance.init(
      navigatorKey: navigatorKey,
      userId: safeId,
      userName: safeName,
    );
  });

  _authSub = FirebaseAuth.instance.authStateChanges().listen((User? u) async {
    if (u == null) {
      ZegoService.instance.uninit();
      return;
    }

    final String userId = u.uid;

    // for ZEGO
    final String rawName = (u.displayName ?? '').trim();
    final String safeName = rawName.isNotEmpty
        ? rawName
        : ((u.phoneNumber ?? '').trim().isNotEmpty
              ? u.phoneNumber!.trim()
              : 'Guest');

    await ZegoService.instance.init(
      navigatorKey: navigatorKey,
      userId: userId,
      userName: safeName,
    );
  });

  runApp(MyApp(navigatorKey: navigatorKey));
}
