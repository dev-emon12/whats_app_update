import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:whats_app/feature/NavBar/navbar.dart';
import 'package:whats_app/feature/authentication/screens/log_in_screen/log_in_screen.dart';
import 'package:whats_app/feature/authentication/screens/verify_screen/verify_screen.dart';
import 'package:whats_app/feature/authentication/screens/welcome_screen.dart';
import 'package:whats_app/feature/personalization/screen/profile/profile.dart';
import 'package:whats_app/utiles/exception/firebase_auth_exceptions.dart';
import 'package:whats_app/utiles/exception/firebase_exceptions.dart';
import 'package:whats_app/utiles/exception/formate_exceptions.dart';
import 'package:whats_app/utiles/exception/platform_exceptions.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String VerifyId = '';
  RxString fullPhone = ''.obs;
  TextEditingController otpController = TextEditingController();
  User? get currentUser => _auth.currentUser;
  final LocalStorage = GetStorage();
  RxBool isPhoneEmpty = true.obs;
  final signUpKey = GlobalKey<FormState>();
  final OTPkey = GlobalKey<FormState>();

  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  // function to redirect to the right screen
  Future<void> screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      // User logged in
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        // User has a verified phone number
        await GetStorage.init(user.uid);

        Get.offAll(() => navigationMenuScreen());
      } else {
        // User logged in but phone not verified
        Get.offAll(() => profile_screen());
      }
    } else {
      // User not logged in
      LocalStorage.writeIfNull("isFirstTime", true);

      final isFirst = LocalStorage.read("isFirstTime");

      if (isFirst == true) {
        Get.offAll(() => welcome_screen());
      } else {
        Get.offAll(() => Log_in_screen());
      }
    }
  }

  // sign_in_with_phone_number
  void SignInWithPhoneNumber() async {
    try {
      // start loading
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      // Check Internet Connectivity
      // bool isConnected = await NetworkManager.instance.isConnected();
      // if (!isConnected) {
      //   MySnackBarHelpers.warningSnackBar(title: "No Internet Connection");
      //   return;
      // }

      // form validation
      if (!signUpKey.currentState!.validate()) {
        return;
      }

      // verify number
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone.string,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseException e) {
          MySnackBarHelpers.errorSnackBar(title: e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          VerifyId = verificationId;
          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "OTP sent on your number",
          );

          MyFullScreenLoader.stopLoading();
          Get.to(verify_screen());
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      Get.back();
      throw "Something went wrong.Please try again";
    }
  }

  // verifuy_with_otp
  void verifyWithOtp() async {
    try {
      // Start loading
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: VerifyId,
        smsCode: otpController.text,
      );
      await _auth.signInWithCredential(credential);
      MySnackBarHelpers.successSnackBar(
        title: "Verified",
        message: "Your number was verified sucessfully",
      );
      MyFullScreenLoader.stopLoading();
      Get.offAll(profile_screen());
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      throw "Something went wrong.Please try again";
    }
  }
}
