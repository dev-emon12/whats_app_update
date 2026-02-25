import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:whats_app/data/service/App_Lifecycle_Service/app_lifecycle_service.dart';
import 'package:whats_app/data/service/notification_service/NotificationService.dart';
import 'package:whats_app/data/service/zego_service.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/authentication/backend/call_repo/call_repo.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/firebase_options.dart';
import 'package:whats_app/my_apps.dart';
import 'data/repository/authentication_repo/AuthenticationRepo.dart';

final navigatorKey = GlobalKey<NavigatorState>();
StreamSubscription<User?>? _authSub;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.instance.ensureInitialized();

  final type = (message.data['type'] ?? '').toString();

  if (type == 'call') {
    await NotificationService.instance.showIncomingCallNotification(
      callerName: (message.data['callerName'] ?? 'Incoming call').toString(),
      data: message.data,
    );
    return;
  }

  final title =
      message.data['senderName']?.toString() ??
      message.notification?.title ??
      'Message';

  final body =
      message.data['message']?.toString() ??
      message.notification?.body ??
      'New message';

  await NotificationService.instance.showChatNotification(
    title: title,
    body: body,
    data: message.data,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize local storage
  await GetStorage.init();
  // initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // notificaiton background handeler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // controllers/repository
  Get.put(AuthenticationRepository(), permanent: true);
  Get.put(UserController(), permanent: true);
  Get.put(AppLifecycleService(), permanent: true);
  Get.put(CallRepo(), permanent: true);

  // notifications
  await NotificationService.instance.init(navigatorKey: navigatorKey);

  // ONE auth listener
  _authSub = FirebaseAuth.instance.authStateChanges().listen((
    User? user,
  ) async {
    if (user == null) {
      ZegoService.instance.uninit();
      return;
    }

    await Messagerepository.initMe();

    //  save FCM token after login
    await Messagerepository.instance.saveFcmToken();

    // for zego call service
    final String userId = user.uid;
    final String safeName =
        (user.displayName ?? user.phoneNumber ?? "Guest").trim().isEmpty
        ? "Guest"
        : (user.displayName ?? user.phoneNumber ?? "Guest").trim();

    final String userPhone = (user.phoneNumber ?? "").trim();

    await ZegoService.instance.initIfNeeded(
      navigatorKey: navigatorKey,
      userId: userId,
      userName: safeName,
      userPhone: userPhone,
    );
  });

  runApp(MyApp(navigatorKey: navigatorKey));
}
