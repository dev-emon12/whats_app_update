import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/firebase_options.dart';
import 'package:whats_app/my_apps.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    Get.put(AuthenticationRepository());
  });
  // if (AuthenticationRepository.instance.currentUser == null) {
  //   // Get.to(welcome_screen());
  // }
  runApp(const MyApp());
}
