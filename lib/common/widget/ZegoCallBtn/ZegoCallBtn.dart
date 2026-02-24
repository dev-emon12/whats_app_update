import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// ignore: must_be_immutable
class ZegoCallInvitationButton extends StatelessWidget {
  ZegoCallInvitationButton({
    super.key,
    required this.otherUser,
    required this.isVideo,
    required this.icon,
    required this.text,
    this.color,
    this.size = 22,
  });

  final UserModel otherUser;
  bool isVideo = true;
  IconData icon;
  final String text;
  final Color? color;
  final double? size;
  @override
  Widget build(BuildContext context) {
    String conversationId(String a, String b) {
      final list = [a, b]..sort();
      return "${list[0]}_${list[1]}";
    }

    final invitees = [
      ZegoUIKitUser(id: otherUser.id, name: otherUser.username),
    ];

    final me = FirebaseAuth.instance.currentUser!;
    final myId = me.uid;
    final convId = conversationId(myId, otherUser.id);

    String newCallId() =>
        "call_${myId}_${DateTime.now().millisecondsSinceEpoch}";
    String customData(String callType) => jsonEncode({
      "conversationId": convId,
      "fromId": myId,
      "fromName": FirebaseAuth.instance.currentUser?.displayName ?? "Me",
      "fromPhone": FirebaseAuth.instance.currentUser?.phoneNumber ?? "",
      "toId": otherUser.id,
      "toName": otherUser.username,
      "toPhone": otherUser.phoneNumber,
      "callType": callType,
      "toImage": otherUser.profilePicture,
    });

    return ZegoSendCallInvitationButton(
      resourceID: "ZegoCall",
      isVideoCall: isVideo,
      invitees: invitees,
      callID: newCallId(),
      customData: customData(text),
      buttonSize: Size(40, 40),
      iconSize: Size(22, 22),
      icon: ButtonIcon(
        icon: Icon(icon, size: size, color: color),
      ),
    );
  }
}
