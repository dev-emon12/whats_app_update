import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/call_repo/call_repo.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    super.key,
    required this.otherUser,
    required this.isVideoCall,
    required this.callId,
  });

  final UserModel otherUser;
  final bool isVideoCall;
  final String callId;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late final String myId;
  late final String myName;
  late final String myPhone;

  late final String otherName;
  late final String otherPhone;

  late final CallType callType;
  late final String conversationId;

  int? startedAt;
  bool answered = false;
  Timer? missTimer;

  @override
  void initState() {
    super.initState();

    final me = FirebaseAuth.instance.currentUser!;
    myId = me.uid;

    final rawName = (me.displayName ?? me.phoneNumber ?? "Guest").trim();
    myName = rawName.isEmpty ? "Guest" : rawName;

    myPhone = (me.phoneNumber ?? "").trim();

    otherName = widget.otherUser.username.trim().isEmpty
        ? "User"
        : widget.otherUser.username.trim();

    otherPhone = (widget.otherUser.phoneNumber ?? "").trim();

    callType = widget.isVideoCall ? CallType.video : CallType.audio;
    conversationId = CallRepo.conversationId(myId, widget.otherUser.id);

    _createRinging();
    _startMissTimeout();
  }

  Future<void> _createRinging() async {
    await CallRepo.upsertCall(
      callId: widget.callId,
      callerId: myId,
      receiverId: widget.otherUser.id,
      callType: callType,
      status: CallStatus.ringing,
      callerName: myName,
      callerPhone: myPhone,
      receiverName: otherName,
      receiverPhone: otherPhone,
    );
  }

  void _startMissTimeout() {
    missTimer = Timer(const Duration(seconds: 30), () async {
      if (!answered && mounted) {
        final now = DateTime.now().millisecondsSinceEpoch;

        await CallRepo.upsertCall(
          callId: widget.callId,
          callerId: myId,
          receiverId: widget.otherUser.id,
          callType: callType,
          status: CallStatus.missed,
          endedAt: now,
          durationSec: 0,
          callerName: myName,
          callerPhone: myPhone,
          receiverName: otherName,
          receiverPhone: otherPhone,
        );

        await CallRepo.saveCallMessage(
          conversationId: conversationId,
          fromId: myId,
          toId: widget.otherUser.id,
          callType: callType,
          status: CallStatus.missed,
          timeMs: now,
          durationSec: 0,
          callId: widget.callId,
        );

        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    missTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 1791254756,
        appSign:
            "6d100a52da23818ae74db2848a4e1dc0d91f09cf1842555b040626051b51ca93",
        userID: myId,
        userName: myName,
        callID: widget.callId,
        config: widget.isVideoCall
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
        events: ZegoUIKitPrebuiltCallEvents(
          user: ZegoCallUserEvents(
            onEnter: (user) async {
              if (user.id == myId) return;
              if (answered) return;

              answered = true;
              missTimer?.cancel();
              startedAt = DateTime.now().millisecondsSinceEpoch;

              await CallRepo.upsertCall(
                callId: widget.callId,
                callerId: myId,
                receiverId: widget.otherUser.id,
                callType: callType,
                status: CallStatus.answered,
                startedAt: startedAt,
                callerName: myName,
                callerPhone: myPhone,
                receiverName: otherName,
                receiverPhone: otherPhone,
              );
            },
          ),
          onCallEnd: (event, defaultAction) async {
            try {
              final endTime = DateTime.now().millisecondsSinceEpoch;
              final durationSec = startedAt == null
                  ? 0
                  : ((endTime - startedAt!) / 1000).floor();

              final finalStatus = answered
                  ? CallStatus.ended
                  : CallStatus.canceled;

              await CallRepo.upsertCall(
                callId: widget.callId,
                callerId: myId,
                receiverId: widget.otherUser.id,
                callType: callType,
                status: finalStatus,
                startedAt: startedAt,
                endedAt: endTime,
                durationSec: durationSec,
                callerName: myName,
                callerPhone: myPhone,
                receiverName: otherName,
                receiverPhone: otherPhone,
              );

              await CallRepo.saveCallMessage(
                conversationId: conversationId,
                fromId: myId,
                toId: widget.otherUser.id,
                callType: callType,
                status: finalStatus,
                timeMs: endTime,
                durationSec: durationSec,
                callId: widget.callId,
              );
            } finally {
              defaultAction.call();
            }
          },
        ),
      ),
    );
  }
}
