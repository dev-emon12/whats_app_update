import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:whats_app/data/service/notification_service/NotificationService.dart';
import 'package:whats_app/firebase_options.dart';
import 'package:whats_app/my_apps.dart';
import 'data/repository/authentication_repo/AuthenticationRepo.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('✅ FCM background: ${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthenticationRepository());

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //  Local notification init
  await NotificationService.instance.initLocalNotifications();
  //  Start listeners
  // NotificationService.instance.initFcmListeners();

  //  Request permission
  await FirebaseMessaging.instance.requestPermission();

  runApp(const MyApp());
}
