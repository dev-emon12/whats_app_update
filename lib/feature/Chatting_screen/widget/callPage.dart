import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/authentication/backend/call_repo/call_repo.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  const CallPage({
    super.key,
    required this.otherUser,
    required this.isVideoCall,
  });

  final UserModel otherUser;
  final bool isVideoCall;

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser!;
    final myId = me.uid;

    final callId = "call_${myId}_${DateTime.now().millisecondsSinceEpoch}";
    final startTime = DateTime.now().millisecondsSinceEpoch;

    final myNameRaw = (me.displayName ?? me.phoneNumber ?? "Guest").trim();
    final myName = myNameRaw.isEmpty ? "Guest" : myNameRaw;

    final callType = isVideoCall ? CallType.video : CallType.audio;
    final conversationId = Messagerepository.getConversationID(otherUser.id);

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 1791254756,
        appSign:
            "6d100a52da23818ae74db2848a4e1dc0d91f09cf1842555b040626051b51ca93",
        userID: myId,
        userName: myName,
        callID: callId,

        //  config
        config: isVideoCall
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),

        // put onCallEnd
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) async {
            try {
              final endTime = DateTime.now().millisecondsSinceEpoch;
              final durationSec = ((endTime - startTime) / 1000).floor();

              // simple status guess (you can improve using invitation events)
              final status = durationSec <= 1
                  ? CallStatus.missed
                  : CallStatus.ended;

              //  Save call history for calls screen
              await CallRepo.saveCallLog(
                callId: callId,
                callerId: myId,
                receiverId: otherUser.id,
                callType: callType,
                direction: CallDirection.outgoing,
                status: status,
                startedAt: startTime,
                endedAt: endTime,
                durationSec: durationSec,
              );

              //  Save as a chat message and shows in chat  last message
              await CallRepo.saveCallMessage(
                conversationId: conversationId,
                fromId: myId,
                toId: otherUser.id,
                callId: callId,
                callType: callType,
                status: status,
                time: endTime,
                durationSec: durationSec,
              );
            } catch (e) {
              debugPrint("onCallEnd save error: $e");
            } finally {
              defaultAction.call();
            }
          },
        ),
      ),
    );
  }
}
