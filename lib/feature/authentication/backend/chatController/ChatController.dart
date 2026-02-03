import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whats_app/binding/enum.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/data/service/cloudinary_service_for_chat.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:dio/dio.dart' as dio;

class ChatController extends GetxController {
  static ChatController get instance => Get.find();

  // repository
  ChatController(this.otherUser);
  final _cloudinaryServicesForChat = Get.put(cloudinaryServicesForChat());
  final _userRepo = Get.put(UserRepository());

  // text controller
  final textController = TextEditingController();

  // user model
  final UserModel otherUser;

  final RxString message = ''.obs;
  final isSending = false.obs;
  // in message long press
  final RxBool isSelecting = false.obs;
  final Rxn<Map<String, dynamic>> selectedMessage = Rxn<Map<String, dynamic>>();
  final selectedMessageText = ''.obs;
  final selectedDocId = ''.obs;

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
    final myId = FirebaseAuth.instance.currentUser!.uid;
    final fromId = (msg['fromId'] ?? '').toString();

    if (fromId != myId) {
      // Other user's message: disable editing
      selectedMessage.value = {
        ...msg,
        'docId': docId,
        'canEdit': false, // mark editable false
      };
    } else {
      selectedMessage.value = {
        ...msg,
        'docId': docId,
        'canEdit': true, // my message: editable
      };
    }

    selectedMessageText.value = (msg['msg'] ?? msg['message'] ?? '').toString();
    selectedDocId.value = docId;
    isSelecting.value = true;
  }

  // on AppBar close
  void clearSelection() {
    selectedMessage.value = null;
    selectedDocId.value = '';
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

  // update Message from chat
  Future<void> updateMessage({
    required String otherUserId,
    required String messageDocId,
    required String newText,
  }) async {
    if (newText.trim().isEmpty) return;

    final cid = Messagerepository.getConversationID(otherUserId);

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(cid)
        .collection("messages")
        .doc(messageDocId)
        .update({
          "msg": newText,
          "message": newText,
          "edited": true,
          "updatedAt": FieldValue.serverTimestamp(),
        });
  }

  // delete chat message
  Future<void> deleteSelectedMessage() async {
    final msg = selectedMessage.value;
    if (msg == null) {
      Get.snackbar(
        "Select a message",
        "Long-press a message first",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final docId = msg['docId']?.toString();
    if (docId == null) {
      Get.snackbar(
        "Error",
        "Missing message id",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final cid = Messagerepository.getConversationID(otherUser.id);

    try {
      // Delete Firestore
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(cid)
          .collection('messages')
          .doc(docId)
          .delete();

      // Delete image
      if ((msg['type'] ?? '').toString().toLowerCase() == 'image') {
        final publicId = msg['cloudinary_public_id']?.toString();
        if (publicId != null && publicId.isNotEmpty) {
          await _cloudinaryServicesForChat.deleteImage(publicId);
        }
      }

      clearSelection();
      Get.snackbar(
        "Deleted",
        "Message deleted successfully",
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      // debugPrint("Delete failed: $e");
      Get.snackbar("Error", "Delete failed", snackPosition: SnackPosition.TOP);
    }
  }

  // download image from chat
  Future<void> downloadImageFormChat() async {
    final msg = selectedMessage.value;
    if (msg == null) {
      Get.snackbar("Error", "No message selected");
      return;
    }

    final type = (msg['type'] ?? '').toString().toLowerCase();
    final imageUrl = msg['msg'] ?? msg['message'] ?? '';

    if (type != 'image' || imageUrl.isEmpty) {
      Get.snackbar("Error", "Selected message is not an image");
      return;
    }

    try {
      // Ask permission for storage
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar("Permission denied", "Cannot download image");
          return;
        }
      }

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/WhataApp');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      // File path
      final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${folder.path}/$fileName';

      // Download using Dio
      await dio.Dio().download(imageUrl, filePath);

      Get.snackbar("Downloaded", "Image saved to ${folder.path}");
    } catch (e) {
      Get.snackbar("Error", "Failed to download image");
      debugPrint("Download failed: $e");
    }
  }

  // copy text from chat
  Future<void> copyText() async {
    await Clipboard.setData(ClipboardData(text: selectedMessageText.value));
    Get.snackbar(
      "Copied",
      "Message copied to clipboard",
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
    // debugPrint("Copied: ${chatC.selectedMessageText.value}");
  }

  // edit message in chat
  Future<void> editChat() async {
    final TextEditingController controller = TextEditingController(
      text: selectedMessageText.value,
    );

    UserController.instance.alertDialog(
      title: "Update Message",
      middleText: "Enter text to update message.",
      content: TextFormField(
        controller: controller,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: selectedMessageText.value,
          labelText: "Message",
        ),
      ),
      onConfirm: () async {
        await updateMessage(
          otherUserId: otherUser.id,
          messageDocId: selectedDocId.value,
          newText: controller.text,
        );

        clearSelection();
        Get.back();
      },
      btnText: 'Update',
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
