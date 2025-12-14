import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/NavBar/navbar.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  Rx<UserModel> user = UserModel.empty().obs;
  final _userRepository = Get.put(UserRepository());
  TextEditingController userName = TextEditingController();

  // Update user profile picture
  Future<void> updateUserProfilePicture() async {
    try {
      // pick image form gallery
      XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
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

  // save user record in firebase
  Future<void> saveUserRecord() async {
    try {
      // start loading
      MyFullScreenLoader.openLoadingDialog(
        "We are processing your information...",
      );
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        throw Exception("No logged in user found");
      }

      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final usernameFromInput = userName.text.trim();

      final updatedData = {
        "id": firebaseUser.uid,
        "username": usernameFromInput.isNotEmpty
            ? usernameFromInput
            : (firebaseUser.displayName ?? "User"),
        "email": firebaseUser.email ?? "",
        "phoneNumber": firebaseUser.phoneNumber ?? "",
        "about": "Hi, there. I'm using WhatsApp",
        "createdAt": time,
        "isOnline": true,
        "lastActive": time,
        "pushToken": "",
      };

      await _userRepository.updateSingleField(updatedData);
      MyFullScreenLoader.stopLoading();
      Get.offAll(() => navigationMenuScreen());
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MySnackBarHelpers.warningSnackBar(
        title: "Data not saved",
        message: "Something went wrong while saving your information",
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
}
