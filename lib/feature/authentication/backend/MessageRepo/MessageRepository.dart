import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/binding/enum.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:whats_app/utiles/popup/SnackbarHepler.dart';

class Messagerepository extends GetxController {
  static Messagerepository get instance => Get.find();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  final isSending = false.obs;
  static late UserModel me;

  // Call this after  UserModel
  Future<void> getFirebaseMessageToken() async {
    await fMessaging.requestPermission();

    final t = await fMessaging.getToken();
    if (t != null) {
      me.pushToken = t;
      print('FCM Token: $t');
    }
  }

  // for sent message
  static Future<void> initMe() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (snap.exists) {
      me = UserModel.fromSnapshot(snap);
    }
  }

  // Build conversation ID between current user and another user
  static String getConversationID(String otherUserId) {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    return myId.hashCode <= otherUserId.hashCode
        ? '${myId}_$otherUserId'
        : '${otherUserId}_$myId';
  }

  // getAllMessage
  static Stream<QuerySnapshot<Map<String, dynamic>>> GetAllMessage(
    UserModel user,
  ) {
    final cid = getConversationID(user.id);
    return FirebaseFirestore.instance
        .collection(MyKeys.chatCollection)
        .doc(cid)
        .collection(MyKeys.messageCollection)
        .orderBy("sent", descending: true)
        .snapshots();
  }

  // sent message
  static Future<void> sendMessage(
    UserModel chatUser,
    String msg,
    MessageType type,
  ) async {
    final String currentUid = FirebaseAuth.instance.currentUser!.uid;
    final cid = getConversationID(chatUser.id);
    final timeId = DateTime.now().millisecondsSinceEpoch.toString();

    final String senderName = Messagerepository.me.username;

    await FirebaseFirestore.instance
        .collection(MyKeys.chatCollection)
        .doc(cid)
        .set({
          "participants": [currentUid, chatUser.id],
          "updatedAt": FieldValue.serverTimestamp(),
          "lastMsg": type == MessageType.image ? "📸 Image" : msg,
          "lastType": type.name,
        }, SetOptions(merge: true));

    // Write message
    await FirebaseFirestore.instance
        .collection(MyKeys.chatCollection)
        .doc(cid)
        .collection(MyKeys.messageCollection)
        .doc(timeId)
        .set({
          'toId': chatUser.id,
          'fromId': currentUid,
          'msg': msg,
          'read': '',
          'type': type.name,
          'sent': FieldValue.serverTimestamp(),
          'senderName': senderName,
        });

    // restore chat for receiver
    await FirebaseFirestore.instance
        .collection(MyKeys.userCollection)
        .doc(chatUser.id)
        .collection('deleted_chats')
        .doc(currentUid)
        .delete()
        .catchError((_) {});

    // restore chat for sender
    await FirebaseFirestore.instance
        .collection(MyKeys.userCollection)
        .doc(currentUid)
        .collection('deleted_chats')
        .doc(chatUser.id)
        .delete()
        .catchError((_) {});
  }

  // getFormattedTime
  static String getFormattedTime({
    required BuildContext context,
    required dynamic time,
  }) {
    final dt = _parseTime(time);
    if (dt == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dt.year, dt.month, dt.day);

    final diffDays = today.difference(messageDay).inDays;
    final timeText = TimeOfDay.fromDateTime(dt).format(context);

    if (diffDays == 0) {
      return "Today, $timeText";
    } else if (diffDays == 1) {
      return "Yesterday, $timeText";
    } else {
      return "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year}, $timeText";
    }
  }

  static DateTime? _parseTime(dynamic time) {
    if (time == null) return null;

    if (time is Timestamp) {
      return time.toDate();
    }

    if (time is String) {
      final ms = int.tryParse(time);
      if (ms != null) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      // try ISO string
      try {
        return DateTime.parse(time);
      } catch (_) {
        return null;
      }
    }

    if (time is DateTime) {
      return time;
    }

    return null;
  }

  // getLastMessageday
  static String getLastMessageday({
    required BuildContext context,
    required dynamic time,
  }) {
    final dt = _parseTime(time);
    if (dt == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(dt.year, dt.month, dt.day);

    final diff = today.difference(thatDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7 && diff > 1) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dt.weekday - 1];
    }
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year.toString().substring(2)}';
  }

  // updateMessageReadStatus
  static Future<void> markMessageAsRead(
    String otherUserId,
    String messageId,
  ) async {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    final cid = getConversationID(
      otherUserId,
    ); // make sure this uses a String id

    await FirebaseFirestore.instance
        .collection('chats/$cid/messages')
        .doc(messageId)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // GetLastMessage
  static Stream<QuerySnapshot<Map<String, dynamic>>> GetLastMessage(
    UserModel user,
  ) {
    final cid = getConversationID(user.id);

    return FirebaseFirestore.instance
        .collection("chats")
        .doc(cid)
        .collection(MyKeys.messageCollection)
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  // getLastMessageTime
  static String getLastMessageTime({
    required BuildContext context,
    required dynamic time,
    bool showYear = false,
  }) {
    if (time == null) return '';

    DateTime sent;

    // time comes as Firestore Timestamp
    if (time is Timestamp) {
      sent = time.toDate();
    }
    // time stored as string milliseconds
    else if (time is String && int.tryParse(time) != null) {
      sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    }
    // already DateTime
    else if (time is DateTime) {
      sent = time;
    } else {
      return '';
    }

    final DateTime now = DateTime.now();

    // Same day
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    // Yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (sent.day == yesterday.day &&
        sent.month == yesterday.month &&
        sent.year == yesterday.year) {
      return "Yesterday";
    }

    // Show full date
    return showYear
        ? "${sent.day} ${_getMonth(sent)} ${sent.year}"
        : "${sent.day} ${_getMonth(sent)}";
  }

  static String _getMonth(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[date.month - 1];
  }

  // unread message count for chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadMessage(
    UserModel user,
  ) {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    final cid = getConversationID(user.id);
    return FirebaseFirestore.instance
        .collection(MyKeys.chatCollection)
        .doc(cid)
        .collection(MyKeys.messageCollection)
        .where('toId', isEqualTo: myId)
        .where('read', isEqualTo: '')
        .snapshots();
  }

  //sent image and upload to cloudinary
  Future<void> sendImageMessage({
    required UserModel otherUser,
    required ImageSource source,
    required Future<dio.Response> Function(File file) uploadFn,
  }) async {
    try {
      // Pick image
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        maxHeight: 1024,
        maxWidth: 1024,
      );
      if (picked == null) return;

      final file = File(picked.path);
      isSending.value = true;

      // Upload to Cloudinary
      final dio.Response res = await uploadFn(file);

      // debugPrint("Cloudinary Response: ${res.data}");

      if (res.statusCode != 200 || res.data == null) {
        throw "Upload failed with status ${res.statusCode}";
      }

      // parse response
      late final Map<String, dynamic> data;

      if (res.data is Map<String, dynamic>) {
        data = res.data as Map<String, dynamic>;
      } else if (res.data is Map) {
        data = Map<String, dynamic>.from(res.data as Map);
      } else {
        throw "Invalid Cloudinary response: ${res.data.runtimeType}";
      }

      final String imageUrl = (data["secure_url"] ?? data["url"] ?? "")
          .toString();

      if (imageUrl.isEmpty) {
        throw "Uploaded image URL is missing.";
      }

      final String? publicId = data["public_id"]?.toString();

      // send the image message into chat
      await Messagerepository.sendMessage(
        otherUser,
        imageUrl,
        MessageType.image,
      );
    } catch (e) {
      MySnackBarHelpers.errorSnackBar(
        title: "Image Send Failed",
        message: e.toString(),
      );
    } finally {
      isSending.value = false;
    }
  }

  // Save fcm token
  // Future<void> saveFcmToken() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;

  //   final token = await FirebaseMessaging.instance.getToken();
  //   if (token == null || token.isEmpty) return;

  //   await _firestore.collection('users').doc(uid).update({'pushToken': token});

  //   print(" FCM token saved: $token");
  // }
}
