import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:whats_app/feature/NavBar/navbar.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/authentication/screens/log_in_screen/log_in_screen.dart';
import 'package:whats_app/feature/authentication/screens/verify_screen/verify_screen.dart';
import 'package:whats_app/feature/authentication/screens/welcome_screen.dart';
import 'package:whats_app/feature/personalization/screen/profile/profile.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verifyId = '';
  RxString fullPhone = ''.obs;

  final TextEditingController otpController = TextEditingController();

  User? get currentUser => _auth.currentUser;

  final GetStorage localStorage = GetStorage();

  final signUpKey = GlobalKey<FormState>();
  final otpKey = GlobalKey<FormState>();

  late final Messagerepository _messageRepo;

  @override
  void onInit() {
    super.onInit();
    _messageRepo = Get.put(Messagerepository());
  }

  @override
  Future<void> onReady() async {
    super.onReady();

    // if already logged in, init FCM + ZEGO
    if (_auth.currentUser != null) {
      await _afterLoginInit();
    }

    FlutterNativeSplash.remove();
    await screenRedirect();
  }

  //  runs only when user is authenticated
  Future<void> _afterLoginInit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // save FCM token
    await _messageRepo.saveFcmToken();
  }

  // Redirect to correct screen
  Future<void> screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        await GetStorage.init(user.uid);
        Get.offAll(() => navigationMenuScreen());
      } else {
        Get.offAll(() => profile_screen());
      }
      return;
    }

    localStorage.writeIfNull("isFirstTime", true);
    final isFirst = localStorage.read("isFirstTime") as bool?;

    if (isFirst == true) {
      Get.offAll(() => welcome_screen());
    } else {
      Get.offAll(() => Log_in_screen());
    }
  }

  // Sign in with phone number
  Future<void> signInWithPhoneNumber() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      if (!signUpKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone.value,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseException e) {
          MyFullScreenLoader.stopLoading();
          MySnackBarHelpers.errorSnackBar(
            title: "Verification Failed",
            message: e.message ?? "Unknown error",
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          verifyId = verificationId;

          MyFullScreenLoader.stopLoading();
          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "OTP sent on your number",
          );

          Get.to(() => verify_screen());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verifyId = verificationId;
        },
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(title: "Failed", message: e.toString());
    }
  }

  // Verify OTP
  Future<void> verifyWithOtp() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      final credential = PhoneAuthProvider.credential(
        verificationId: verifyId,
        smsCode: otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);

      // ✅ After login: save fcm + init ZEGO
      await _afterLoginInit();

      MyFullScreenLoader.stopLoading();

      MySnackBarHelpers.successSnackBar(
        title: "Verified",
        message: "Your number was verified successfully",
      );

      Get.offAll(() => profile_screen());
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(
        title: "OTP Failed",
        message: e.toString(),
      );
    }
  }

  // getSafeUserNameFromFirestore
  Future<String> getSafeUserNameFromFirestore(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = snap.data();
    final name = (data?['username'] ?? '').toString().trim();
    if (name.isNotEmpty) return name;

    final phone = FirebaseAuth.instance.currentUser?.phoneNumber?.trim() ?? '';
    return phone.isNotEmpty ? phone : 'Guest';
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
