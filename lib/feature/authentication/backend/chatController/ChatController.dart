import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/binding/enum.dart';
import 'package:whats_app/data/service/cloudinary_service_for_chat.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:dio/dio.dart' as dio;

class ChatController extends GetxController {
  static ChatController get instance => Get.find();

  // repository
  ChatController(this.otherUser);
  final _cloudinaryServicesForChat = Get.put(cloudinaryServicesForChat());

  // text controller
  final textController = TextEditingController();

  // user model
  final UserModel otherUser;

  final RxString message = ''.obs;
  final isSending = false.obs;
  // in message long press
  final RxBool isSelecting = false.obs;
  final Rxn<Map<String, dynamic>> selectedMessage = Rxn<Map<String, dynamic>>();
  final RxnString selectedDocId = RxnString();

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      message.value = textController.text;
    });
  }

  // on MessageCard long press
  void selectMessage({
    required Map<String, dynamic> msg,
    required String docId,
  }) {
    selectedMessage.value = msg;
    selectedDocId.value = docId;
    isSelecting.value = true;
  }

  // on AppBar close
  void clearSelection() {
    selectedMessage.value = null;
    selectedDocId.value = null;
    isSelecting.value = false;
  }

  // for AppBar button download and detele image
  bool get selectedIsImage {
    final type = (selectedMessage.value?['type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return type == 'image';
  }

  // sendMessage
  Future<void> sendMessage() async {
    if (message.value.trim().isEmpty) return;

    isSending.value = true;
    try {
      await Messagerepository.sendMessage(
        otherUser,
        message.value,
        MessageType.text,
      );
      textController.clear();
    } finally {
      isSending.value = false;
    }
  }

  // sent picture form cloudinary
  Future<dio.Response> sentPicture(File image) async {
    return _cloudinaryServicesForChat.uploadImage(image, MyKeys.uploadImage);
  }

  //  Delete profile picture form cloudinary
  // Future<dio.Response> deleteProfilePicture(String publicId) async {
  //   try {
  //     dio.Response response = await _coludnaryServcies.deleteImage(publicId);
  //     return response;
  //   } catch (e) {
  //     throw "Something went wrong. Please try again";
  //   }
  // }

  // Image sending logic from camera
  Future<void> sendImageFromCamera() async {
    await Messagerepository.instance.sendImageMessage(
      otherUser: otherUser,
      uploadFn: sentPicture,
      source: ImageSource.camera,
    );
  }

  // Image sending logic from gallery
  Future<void> sendImageFromGallery() async {
    await Messagerepository.instance.sendImageMessage(
      otherUser: otherUser,
      uploadFn: sentPicture,
      source: ImageSource.gallery,
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
