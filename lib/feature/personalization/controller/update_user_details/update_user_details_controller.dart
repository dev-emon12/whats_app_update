import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/utiles/popup/MyFullScreenLoader.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';

class UpdateUserDetailsController extends GetxController {
  static UpdateUserDetailsController get instance => Get.find();

  // form key
  final upDateUserNameFormKey = GlobalKey<FormState>();
  final upDateUserAboutFormKey = GlobalKey<FormState>();
  final upDateUserNumberFormKey = GlobalKey<FormState>();

  // controller
  final userController = UserController.instance;
  final UserRepository userRepo = Get.put(UserRepository());

  // textFiled
  final username = TextEditingController();
  final about = TextEditingController();
  final phoneNumberFirst = TextEditingController();
  final phoneNumberSecond = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initializeNames();
  }

  void initializeNames() {
    username.text = userController.user.value.username;
    about.text = userController.user.value.about;
    phoneNumberFirst.text = userController.user.value.phoneNumber;
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
}
