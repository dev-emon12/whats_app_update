import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/user_profile.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/phone_number_change/otp_screen.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';

class UpdateUserDetailsController extends GetxController {
  static UpdateUserDetailsController get instance => Get.find();

  // form key
  final upDateUserNameFormKey = GlobalKey<FormState>();
  final upDateUserAboutFormKey = GlobalKey<FormState>();
  final upDateUserNumberFormKey = GlobalKey<FormState>();
  final upDateUserOtpFormKey = GlobalKey<FormState>();
  final upDateUserEmailFormKey = GlobalKey<FormState>();

  // controller
  final userController = UserController.instance;
  final UserRepository userRepo = Get.put(UserRepository());

  // textFiled
  final username = TextEditingController();
  final about = TextEditingController();
  final phoneNumberFirst = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final reAuthenticate = TextEditingController();

  RxString fullPhone = ''.obs;
  String verifyId = '';
  bool _isSendingOtp = false;
  int? _resendToken;

  @override
  void onInit() {
    super.onInit();
    initializeNames();
  }

  void initializeNames() {
    username.text = userController.user.value.username;
    about.text = userController.user.value.about;
    phoneNumberFirst.text = userController.user.value.phoneNumber;
    emailController.text = userController.user.value.email;
    reAuthenticate.text = userController.user.value.phoneNumber;
  }

  // for update user Name
  Future<void> updateUserName() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        'We are updating your information...',
      );

      if (!upDateUserNameFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      Map<String, dynamic> map = {"username": username.text};

      userController.user.value.username = username.text;

      await userRepo.updateSingleField(map);

      userController.user.refresh();
      MyFullScreenLoader.stopLoading();
      Get.back();
      MySnackBarHelpers.successSnackBar(
        title: "Congratulations",
        message: "Your name has been updated",
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(
        title: "Update named failed!",
        message: e.toString(),
      );
      print("Error $e");
    }
  }

  // for update user About
  Future<void> updateUserAbout() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        'We are updating your information...',
      );

      if (!upDateUserAboutFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }
      Map<String, dynamic> map = {"about": about.text};

      userController.user.value.about = about.text;

      await userRepo.updateSingleField(map);

      userController.user.refresh();
      MyFullScreenLoader.stopLoading();
      Get.back();
      MySnackBarHelpers.successSnackBar(
        title: "Congratulations",
        message: "Your about has been updated",
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(
        title: "Update about failed!",
        message: e.toString(),
      );
    }
  }

  //--------------- CHANGE NUMBER SECTION--------------

  // Send Otp To New Number
  Future<void> sendOtpToNewNumber() async {
    if (_isSendingOtp) return;
    _isSendingOtp = true;

    try {
      MyFullScreenLoader.openLoadingDialog("Sending OTP...");

      final form = upDateUserNumberFormKey.currentState;
      if (form == null || !form.validate()) {
        MyFullScreenLoader.stopLoading();
        _isSendingOtp = false;
        return;
      }

      final phone = fullPhone.value.trim().replaceAll(' ', '');
      if (phone.isEmpty || !phone.startsWith('+')) {
        MyFullScreenLoader.stopLoading();
        _isSendingOtp = false;
        MySnackBarHelpers.errorSnackBar(
          title: "Invalid Number",
          message: "Use country code",
        );
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          // optional: auto verification
        },

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

          MyFullScreenLoader.stopLoading();
          _isSendingOtp = false;

          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "OTP sent to $phone",
          );

          Get.to(() => ChangeNumberOtpScreen(verificationId: verificationId));
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          verifyId = verificationId;
          _isSendingOtp = false;
        },
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      _isSendingOtp = false;
      MySnackBarHelpers.errorSnackBar(title: "Failed", message: e.toString());
    }
  }

  // Confirm New Number Otp
  Future<void> confirmNewNumberOtp() async {
    try {
      MyFullScreenLoader.openLoadingDialog("Verifying code...");

      // validate otp form
      final form = upDateUserOtpFormKey.currentState;
      if (form == null || !form.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      final otp = otpController.text.trim();
      if (otp.length != 6) {
        MyFullScreenLoader.stopLoading();
        MySnackBarHelpers.errorSnackBar(
          title: "Invalid Code",
          message: "Enter a valid 6-digit OTP.",
        );
        return;
      }

      if (verifyId.trim().isEmpty) {
        MyFullScreenLoader.stopLoading();
        MySnackBarHelpers.errorSnackBar(
          title: "Session Expired",
          message: "Please request OTP again.",
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        MyFullScreenLoader.stopLoading();
        MySnackBarHelpers.errorSnackBar(
          title: "Error",
          message: "User not logged in.",
        );
        return;
      }

      final newPhone = fullPhone.value.trim().replaceAll(' ', '');
      if (newPhone.isEmpty || !newPhone.startsWith('+')) {
        MyFullScreenLoader.stopLoading();
        MySnackBarHelpers.errorSnackBar(
          title: "Invalid Number",
          message: "Use country code",
        );
        return;
      }

      //  create credential
      final phoneCred = PhoneAuthProvider.credential(
        verificationId: verifyId.trim(),
        smsCode: otp,
      );

      // update firebase auth phone
      await user.updatePhoneNumber(phoneCred);

      //  update firestore
      await userRepo.updateSingleField({"phoneNumber": newPhone});

      //  update GetX user object
      userController.user.update((u) {
        if (u == null) return;
        u.phoneNumber = newPhone;
      });
      userController.user.refresh();

      MyFullScreenLoader.stopLoading();

      MySnackBarHelpers.successSnackBar(
        title: "Success",
        message: "Phone number updated successfully.",
      );

      Get.offAll(() => UserProfile());
    } on FirebaseAuthException catch (e) {
      MyFullScreenLoader.stopLoading();

      if (e.code == "requires-recent-login") {
        MySnackBarHelpers.errorSnackBar(
          title: "Re-authentication required",
          message: "Login again then try changing number.",
        );
        return;
      }

      MySnackBarHelpers.errorSnackBar(
        title: "Failed",
        message: e.message ?? e.code,
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(title: "Error", message: e.toString());
    }
  }

  //--------------- CHANGE NUMBER SECTION END--------------

  // for update user Email
  Future<void> updateUserEmail() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        'We are updating your information...',
      );

      if (!upDateUserEmailFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }
      Map<String, dynamic> map = {"email": emailController.text};

      userController.user.value.email = emailController.text;

      await userRepo.updateSingleField(map);

      userController.user.refresh();
      MyFullScreenLoader.stopLoading();
      Get.back();
      MySnackBarHelpers.successSnackBar(
        title: "Congratulations",
        message: "Your e-mail has been updated",
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(
        title: "Update e-mail failed!",
        message: e.toString(),
      );
    }
  }
}
