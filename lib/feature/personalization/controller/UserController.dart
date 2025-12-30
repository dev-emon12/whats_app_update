import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/NavBar/navbar.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/screens/welcome_screen.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs;
  final _userRepository = Get.put(UserRepository());
  bool _isSendingOtp = false;
  String verifyId = '';

  // text fields
  final userName = TextEditingController();
  final reAuthenticate = TextEditingController();
  final otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  // Update User Profile Picture From Camera
  Future<void> updateUserProfilePictureFromCamera() async {
    await updatePicture(ImageSource.camera);
  }

  // Update User Profile Picture From Gallery
  Future<void> updateUserProfilePictureFromGallery() async {
    await updatePicture(ImageSource.gallery);
  }

  // Update user profile picture
  Future<void> updatePicture(ImageSource source) async {
    try {
      // pick image form gallery
      XFile? image = await ImagePicker().pickImage(
        source: source,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (image == null) return;

      // convert XFile to file
      File file = File(image.path);

      // delete user current profile picture
      if (user.value.publicId.isNotEmpty) {
        await _userRepository.deleteProfilePicture(user.value.publicId);
      }

      // upload picture to cloudinary
      dio.Response response = await _userRepository.updateProfilePicture(file);
      if (response.statusCode == 200) {
        final data = response.data;
        final imageUrl = data["url"];
        final publicId = data["public_id"];

        // update profile picture from firestore
        _userRepository.updateSingleField({
          "profilePicture": imageUrl,
          "publicId": publicId,
        });

        //  update Obx
        user.update((val) {
          if (val == null) return;
          val.profilePicture = imageUrl;
          val.publicId = publicId;
        });

        // update profile and public id form RxUser
        user.value.profilePicture = imageUrl;
        user.value.publicId = publicId;
        user.refresh();
        MySnackBarHelpers.successSnackBar(
          title: "Congratulation",
          message: 'Profile picture update successfully',
        );
      } else {
        throw "Failed to upload profile picture.Please try again";
      }
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(title: "Failed!", message: e.toString());
    }
  }

  // load Current User
  Future<void> loadCurrentUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final fetchedUser = await _userRepository.getUserById(uid);
      user.refresh();
      user.value = fetchedUser!;
    } catch (e) {
      debugPrint("Failed to load user: $e");
    }
  }

  // save user record in firebase
  Future<void> saveUserRecord() async {
    try {
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) throw Exception("No logged in user found");

      final time = DateTime.now().millisecondsSinceEpoch.toString();

      //   make a valid username
      final inputName = userName.text.trim();
      final fallbackName =
          (firebaseUser.displayName?.trim().isNotEmpty ?? false)
          ? firebaseUser.displayName!.trim()
          : (firebaseUser.phoneNumber?.trim().isNotEmpty ?? false)
          ? firebaseUser.phoneNumber!.trim()
          : "Guest";

      final finalUserName = inputName.isNotEmpty ? inputName : fallbackName;

      await firebaseUser.updateDisplayName(finalUserName);
      await firebaseUser.reload();

      final updatedData = {
        "id": firebaseUser.uid,
        "username": finalUserName,
        "email": firebaseUser.email ?? "",
        "phoneNumber": firebaseUser.phoneNumber ?? "",
        "about": "Hi, there. I'm using WhatsApp",
        "createdAt": time,
        "isOnline": true,
        "lastActive": time,
      };
      await _userRepository.updateSingleField(updatedData);
      await FirebaseAuth.instance.currentUser!.updateDisplayName(finalUserName);
      await FirebaseAuth.instance.currentUser!.reload();
      // await AuthenticationRepository.instance.cacheUser(user.value);

      MyFullScreenLoader.stopLoading();
      Get.offAll(() => navigationMenuScreen());
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(
        title: "Data not saved",
        message: e.toString(),
      );
    }
  }

  // updateActiveStatus
  Future<void> updateActiveStatus(bool isOnline) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Update active status failed: $e");
    }
  }

  static String _getmonth(DateTime date) {
    switch (date.month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
    }
    return "";
  }

  // getMessageTime
  static String getMessageTime({
    required BuildContext context,
    required String time,
  }) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formatedTime = TimeOfDay.fromDateTime(sent).format(context);

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formatedTime;
    }
    return now.year == sent.year
        ? "$formatedTime - ${sent.day} ${_getmonth(sent)}"
        : "$formatedTime - ${sent.day} ${_getmonth(sent)} ${sent.year}";
  }

  // getLastActiveTime
  String buildOnlineStatusText({
    required BuildContext context,
    required bool isOnline,
    required String lastActive,
  }) {
    if (isOnline) return 'Online';

    if (lastActive.isEmpty) return 'Last seen recently';

    final ms = int.tryParse(lastActive);
    if (ms == null) return 'Last seen recently';

    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(thatDay).inDays;

    final timeStr = TimeOfDay.fromDateTime(dt).format(context);

    if (diffDays == 0) return 'Last seen today at $timeStr';
    if (diffDays == 1) return 'Last seen yesterday at $timeStr';

    return 'Last seen on ${dt.day}/${dt.month}/${dt.year} at $timeStr';
  }

  // Delete account warning popup
  Future<void> deleteAccountWarningPopup({
    required String title,
    String? middleText,
    required VoidCallback onConfirm,
    Widget? content,
  }) async {
    Get.defaultDialog(
      title: title,
      contentPadding: EdgeInsets.all(Mysize.md),
      middleText: middleText!,
      content: content,
      textCancel: null,
      textConfirm: null,
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
      confirm: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Mysize.lg),
          child: const Text("Delete"),
        ),
      ),
    );
  }

  //-------------DELETE ACCOUNT SECTION-------------
  // Send Otp To New Number
  Future<void> sendOtpForDelete() async {
    if (_isSendingOtp) return;
    _isSendingOtp = true;

    try {
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );

      final phoneText = reAuthenticate.text.trim();

      if (phoneText.isEmpty) {
        MyFullScreenLoader.stopLoading();
        _isSendingOtp = false;
        MySnackBarHelpers.errorSnackBar(
          title: "Invalid Number",
          message: "Phone number must be in a format.",
        );
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneText,
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

          MyFullScreenLoader.stopLoading();
          _isSendingOtp = false;

          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "OTP sent to $phoneText",
          );
          debugPrint("Sending OTP to: $phoneText");

          //  Open otp dialog directly
          deleteAccountWarningPopup(
            title: "Delete Account",
            middleText: "Don't share your OTP with anyone.",
            content: TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "OTP Code",
                hintText: "Enter 6-digit OTP",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),
            onConfirm: () => confirmDeleteOtp(),
          );
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

  // Confirm Delete Otp
  Future<void> confirmDeleteOtp() async {
    try {
      final otp = otpController.text.trim();
      if (otp.length != 6) {
        MySnackBarHelpers.errorSnackBar(
          title: "Invalid OTP",
          message: "Enter a valid 6-digit OTP.",
        );
        return;
      }

      if (verifyId.isEmpty) {
        MySnackBarHelpers.errorSnackBar(
          title: "Session Expired",
          message: "Please request OTP again.",
        );
        return;
      }

      MyFullScreenLoader.openLoadingDialog("Verifying OTP...");

      final credential = PhoneAuthProvider.credential(
        verificationId: verifyId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
        credential,
      );
      await AuthenticationRepository.instance.deleteAccount();

      MyFullScreenLoader.stopLoading();
      Get.offAll(welcome_screen());

      MySnackBarHelpers.successSnackBar(
        title: "Deleted",
        message: "Your account has been deleted.",
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(title: "Failed", message: e.toString());
    }
  }

  //-------------DELETE ACCOUNT SECTION END-------------
}
