import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/binding/binding.dart';
import 'package:whats_app/data/service/cloudinary_service_for_chat.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:dio/dio.dart' as dio;

class ChatController extends GetxController {
  static ChatController get instance => Get.find();
  ChatController(this.otherUser);
  final UserModel otherUser;
  final textController = TextEditingController();
  final _cloudinaryServicesForChat = Get.put(cloudinaryServicesForChat());
  final RxString message = ''.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      message.value = textController.text;
    });
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
