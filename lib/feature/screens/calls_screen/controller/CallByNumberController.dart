import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart'
    show UserModel;
import 'package:whats_app/utiles/const/keys.dart';

class CallByNumberController extends GetxController {
  static CallByNumberController get instance => Get.find();

  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final foundUser = Rxn<UserModel>();
  final errorText = RxnString();

  // search user
  Future<void> searchUser() async {
    final raw = phoneController.text.trim();

    if (raw.isEmpty) {
      errorText.value = "Please enter name or phone number";
      foundUser.value = null;
      return;
    }

    isLoading.value = true;
    errorText.value = null;
    foundUser.value = null;

    try {
      final user = await _searchUserByNameOrPhone(raw);

      foundUser.value = user;

      if (user == null) {
        errorText.value = "No user found";
      }
    } catch (e) {
      errorText.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  //find user
  Future<UserModel?> _searchUserByNameOrPhone(String input) async {
    final value = input.trim();
    final isPhone = RegExp(r'^[0-9+]+$').hasMatch(value);

    QuerySnapshot<Map<String, dynamic>> snap;

    if (isPhone) {
      final normalized = _normalizePhone(value);

      snap = await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .where("phoneNumber", isEqualTo: normalized)
          .limit(1)
          .get();
    } else {
      snap = await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .where("username", isEqualTo: value)
          .limit(1)
          .get();
    }

    if (snap.docs.isEmpty) return null;

    return UserModel.fromSnapshot(snap.docs.first);
  }

  // normalize phone number
  String _normalizePhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('0')) {
      return '+880${digits.substring(1)}';
    }
    if (digits.startsWith('880')) {
      return '+$digits';
    }
    return '+$digits';
  }

  void reset() {
    phoneController.clear();
    foundUser.value = null;
    errorText.value = null;
    isLoading.value = false;
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
