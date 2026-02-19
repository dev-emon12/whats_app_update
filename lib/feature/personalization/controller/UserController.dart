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
import 'package:whats_app/utiles/const/keys.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  // repository/controller
  final _userRepository = Get.put(UserRepository());

  bool _isSendingOtp = false;
  String verifyId = '';
  Rx<UserModel> user = UserModel.empty().obs;
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
      // bool isConnected = await NetworkManager.instance.isConnected();
      // if (!isConnected) {
      //   MyFullScreenLoader.stopLoading();
      //   return;
      // }

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
      Get.offAll(() => NavigationMenuScreen());
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.errorSnackBar(
        title: "Data not saved",
        message: e.toString(),
      );
      debugPrint("Error $e");
    }
  }

  // updateActiveStatus
  Future<void> updateActiveStatus(bool isOnline) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .doc(uid)
          .update({
            'isOnline': isOnline,
            'lastActive': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("updateActiveStatus failed: $e");
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

  //  warning popup
  Future<void> alertDialog({
    required String title,
    String? middleText,
    required VoidCallback onConfirm,
    Widget? content,
    required String btnText,
  }) async {
    Get.defaultDialog(
      backgroundColor: const Color.fromARGB(198, 115, 115, 115),
      title: title,
      contentPadding: EdgeInsets.all(Mysize.md),
      middleText: middleText ?? "",
      content: content,
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: Text('Cancel'),
      ),
      confirm: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: BorderSide(color: Colors.red),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Mysize.lg),
          child: Text(btnText),
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
      MyFullScreenLoader.openLoadingDialog("Sending verification code...");

      final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

      if (phone.isEmpty) {
        MyFullScreenLoader.stopLoading();
        _isSendingOtp = false;
        MySnackBarHelpers.errorSnackBar(
          title: "Error",
          message: "No phone number found for this account.",
        );
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),

        verificationCompleted: (_) {},

        verificationFailed: (e) {
          MyFullScreenLoader.stopLoading();
          _isSendingOtp = false;
          MySnackBarHelpers.errorSnackBar(
            title: "Verification Failed",
            message: e.message ?? e.code,
          );
        },

        codeSent: (verificationId, _) {
          verifyId = verificationId;
          _isSendingOtp = false;
          MyFullScreenLoader.stopLoading();

          MySnackBarHelpers.successSnackBar(
            title: "OTP Sent",
            message: "Verification code sent",
          );

          alertDialog(
            title: "Delete Account",
            middleText: "Enter the OTP sent to your phone.",
            content: TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: "OTP"),
            ),
            onConfirm: confirmDeleteOtp,
            btnText: 'Delete',
          );
        },

        codeAutoRetrievalTimeout: (id) {
          verifyId = id;
          _isSendingOtp = false;
        },
      );
    } finally {
      _isSendingOtp = false;
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

  // download user image
  Future<void> downloadUserImage(String imageUrl) async {
    try {
      final directory = Directory(
        '/storage/emulated/0/Pictures/WhatsApp Images',
      );

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savePath = '${directory.path}/$fileName';

      await dio.Dio().download(imageUrl, savePath);

      Get.snackbar(
        "Downloaded",
        "Image saved to Gallery",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint("Download error: $e");
      Get.snackbar("Error", "Failed to download image");
    }
  }
}
