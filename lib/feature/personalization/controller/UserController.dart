import 'dart:io';
import 'package:flutter/cupertino.dart';
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

  // get MyFullScreenLoader => null;

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
}
