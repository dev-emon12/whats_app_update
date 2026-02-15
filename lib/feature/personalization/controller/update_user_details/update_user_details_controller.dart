import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/personalization/user_profile/user_profile.dart';
import 'package:whats_app/feature/personalization/user_profile/widgets/update_fields/phone_number_change/otp_screen.dart';
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
  int? _forceResendToken;
  bool _isResending = false;

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

      //  validate OTP form
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

      //  verifyId must exist
      if (verifyId.trim().isEmpty) {
        MyFullScreenLoader.stopLoading();
        MySnackBarHelpers.errorSnackBar(
          title: "Session Expired",
          message: "Please resend OTP again.",
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

      // create credential
      final phoneCred = PhoneAuthProvider.credential(
        verificationId: verifyId.trim(),
        smsCode: otp,
      );

      //  update Firebase Auth phone
      await user.updatePhoneNumber(phoneCred);

      //  update Firestore
      await userRepo.updateSingleField({"phoneNumber": newPhone});

      //  update GetX user
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
      //  number already belongs to another account
      if (e.code == "credential-already-in-use" ||
          e.code == "phone-number-already-exists") {
        MySnackBarHelpers.errorSnackBar(
          title: "Number already in use",
          message: "This phone is linked to another account.",
        );
        return;
      }
      //  requires recent login
      if (e.code == "requires-recent-login") {
        MySnackBarHelpers.errorSnackBar(
          title: "Re-authentication required",
          message: "Please login again then try changing number.",
        );
        return;
      }
      //  OTP expired / invalid
      if (e.code == "session-expired" ||
          e.code == "invalid-verification-code") {
        MySnackBarHelpers.errorSnackBar(
          title: "OTP Expired",
          message: "Please resend OTP and try again.",
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

  // Resend Change Number Otp
  Future<void> resendChangeNumberOtp() async {
    if (_isResending) return;
    _isResending = true;

    try {
      final phone = fullPhone.value.trim().replaceAll(' ', '');

      if (phone.isEmpty || !phone.startsWith('+')) {
        _isResending = false;
        MySnackBarHelpers.errorSnackBar(
          title: "Invalid Number",
          message: "Use country code",
        );
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        forceResendingToken: _forceResendToken,

        verificationCompleted: (_) {},

        verificationFailed: (FirebaseAuthException e) {
          _isResending = false;
          MySnackBarHelpers.errorSnackBar(
            title: "Resend Failed",
            message: e.message ?? e.code,
          );
        },

        codeSent: (String newVerificationId, int? resendToken) {
          verifyId = newVerificationId;
          _forceResendToken = resendToken;
          _isResending = false;

          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "A new OTP has been sent",
          );
        },

        codeAutoRetrievalTimeout: (String id) {
          verifyId = id;
          _isResending = false;
        },
      );
    } catch (e) {
      _isResending = false;
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

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
