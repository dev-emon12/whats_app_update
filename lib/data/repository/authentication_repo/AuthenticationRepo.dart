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
  TextEditingController otpController = TextEditingController();

  User? get currentUser => _auth.currentUser;

  final localStorage = GetStorage();

  final signUpKey = GlobalKey<FormState>();
  final otpKey = GlobalKey<FormState>();
  final _messageRepo = Get.put(Messagerepository());

  @override
  Future<void> onReady() async {
    super.onReady();
    if (_auth.currentUser != null) {
      await Messagerepository.instance.saveFcmToken();
    }

    FlutterNativeSplash.remove();
    screenRedirect();
  }

  // function to redirect to the right screen
  Future<void> screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        await GetStorage.init(user.uid);
        Get.offAll(() => navigationMenuScreen());
      } else {
        Get.offAll(() => profile_screen());
      }
    } else {
      localStorage.writeIfNull("isFirstTime", true);
      final isFirst = localStorage.read("isFirstTime");

      if (isFirst == true) {
        Get.offAll(() => welcome_screen());
      } else {
        Get.offAll(() => Log_in_screen());
      }
    }
  }

  // sign_in_with_phone_number
  void signInWithPhoneNumber() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      if (!signUpKey.currentState!.validate()) return;

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone.value,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseException e) {
          MyFullScreenLoader.stopLoading();
          MySnackBarHelpers.errorSnackBar(title: "Something went wrong");
        },
        codeSent: (String verificationId, int? resendToken) {
          verifyId = verificationId;

          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "OTP sent on your number",
          );

          MyFullScreenLoader.stopLoading();
          Get.to(() => verify_screen());
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      Get.back();
      MySnackBarHelpers.errorSnackBar(title: "Failed", message: e.toString());
    }
  }

  // verify_with_otp
  void verifyWithOtp() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      final credential = PhoneAuthProvider.credential(
        verificationId: verifyId,
        smsCode: otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);

      // save token
      await _messageRepo.saveFcmToken();

      MyFullScreenLoader.stopLoading();

      MySnackBarHelpers.successSnackBar(
        title: "Verified",
        message: "Your number was verified successfully",
      );

      Get.offAll(() => profile_screen());
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      Get.back();
      MySnackBarHelpers.errorSnackBar(
        title: "OTP Failed",
        message: e.toString(),
      );
    }
  }
}
