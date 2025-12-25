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
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/personalization/screen/profile/create_profile.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verifyId = '';
  int? _resendToken;
  bool _isSendingOtp = false;

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

    final user = await _auth.authStateChanges().first;

    if (user != null) {
      await _afterLoginInit();
    }

    FlutterNativeSplash.remove();
    await screenRedirect(user);
  }

  Future<void> _afterLoginInit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // await _messageRepo.saveFcmToken();
  }

  // screenRedirect
  Future<void> screenRedirect(User? user) async {
    if (user != null) {
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        await GetStorage.init(user.uid);

        if (user.displayName == null || user.displayName!.trim().isEmpty) {
          Get.offAll(() => profile_screen());
        } else {
          Get.offAll(() => navigationMenuScreen());
        }
      } else {
        Get.offAll(() => Log_in_screen());
      }
      return;
    }

    localStorage.writeIfNull("isFirstTime", true);
    final bool isFirstTime = localStorage.read("isFirstTime") ?? true;

    if (isFirstTime) {
      Get.offAll(() => welcome_screen());
    } else {
      Get.offAll(() => Log_in_screen());
    }
  }

  //  SEND OTP
  Future<void> signInWithPhoneNumber() async {
    if (_isSendingOtp) return;
    _isSendingOtp = true;

    try {
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      if (!signUpKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        _isSendingOtp = false;
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone.value.trim(),
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) {},

        verificationFailed: (FirebaseAuthException e) {
          MyFullScreenLoader.stopLoading();
          _isSendingOtp = false;
          MySnackBarHelpers.errorSnackBar(
            title: "Verification Failed",
            message: e.message ?? e.code,
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          verifyId = verificationId;
          _resendToken = resendToken;

          MyFullScreenLoader.stopLoading();
          _isSendingOtp = false;

          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "OTP sent on your number",
          );

          Get.to(() => verify_screen());
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          verifyId = verificationId;
          _isSendingOtp = false;
        },
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      Get.back();
      _isSendingOtp = false;
      MySnackBarHelpers.errorSnackBar(title: "Failed", message: e.toString());
    }
  }

  // RESEND OTP
  Future<void> resendOtp() async {
    if (_isSendingOtp) return;
    _isSendingOtp = true;

    try {
      MyFullScreenLoader.openLoadingDialog("Resending OTP...");

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone.value.trim(),
        timeout: const Duration(seconds: 60),

        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential credential) {},

        verificationFailed: (FirebaseAuthException e) {
          MyFullScreenLoader.stopLoading();
          _isSendingOtp = false;
          MySnackBarHelpers.errorSnackBar(
            title: "Resend Failed",
            message: e.message ?? e.code,
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          verifyId = verificationId;
          _resendToken = resendToken;

          MyFullScreenLoader.stopLoading();
          _isSendingOtp = false;

          MySnackBarHelpers.successSnackBar(
            title: "OTP Resent",
            message: "A new OTP has been sent",
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          verifyId = verificationId;
          _isSendingOtp = false;
        },
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      Get.back();
      _isSendingOtp = false;
      MySnackBarHelpers.errorSnackBar(
        title: "Resend Failed",
        message: e.toString(),
      );
    }
  }

  //  VERIFY OTP
  Future<void> verifyWithOtp() async {
    try {
      if (verifyId.trim().isEmpty) {
        MySnackBarHelpers.errorSnackBar(
          title: "Session expired",
          message: "Please resend OTP",
        );
        return;
      }

      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      final credential = PhoneAuthProvider.credential(
        verificationId: verifyId,
        smsCode: otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);

      await _afterLoginInit();
      print("error is $credential");

      MyFullScreenLoader.stopLoading();

      MySnackBarHelpers.successSnackBar(
        title: "Verified",
        message: "Your number was verified successfully",
      );

      Get.offAll(() => profile_screen());
    } on FirebaseAuthException catch (e) {
      MyFullScreenLoader.stopLoading();
      Get.back();
      MySnackBarHelpers.errorSnackBar(
        title: "OTP Failed",
        message: e.message ?? e.code,
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      Get.back();
      MySnackBarHelpers.errorSnackBar(
        title: "OTP Failed",
        message: e.toString(),
      );
    }
  }

  // Get Safe User Name From Firestore
  Future<String> getSafeUserNameFromFirestore(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection(MyKeys.userCollection)
        .doc(uid)
        .get();

    if (!doc.exists) {
      return FirebaseAuth.instance.currentUser?.phoneNumber ?? "Guest";
    }

    final data = doc.data();
    final name = (data?['username'] ?? '').toString().trim();

    if (name.isNotEmpty) return name;

    return FirebaseAuth.instance.currentUser?.phoneNumber ?? "Guest";
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
