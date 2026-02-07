import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:whats_app/binding/enum.dart' as enums;
import 'package:whats_app/feature/authentication/backend/call_repo/call_repo.dart'
    as repo;

class ZegoService {
  ZegoService._();
  static final ZegoService instance = ZegoService._();

  bool _inited = false;

  late String _myId;
  late String _myName;
  late String _myPhone;

  String? _lastOutgoingCallId;

  final Map<String, Map<String, dynamic>> _callData = {};

  Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
    required String userId,
    required String userName,
    String userPhone = "",
  }) {
    return initIfNeeded(
      navigatorKey: navigatorKey,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
    );
  }

  Future<void> initIfNeeded({
    required GlobalKey<NavigatorState> navigatorKey,
    required String userId,
    required String userName,
    required String userPhone,
  }) async {
    if (_inited) return;

    _myId = userId.trim();
    _myName = userName.trim().isEmpty ? "Guest" : userName.trim();
    _myPhone = userPhone.trim();

    if (_myId.isEmpty) return;

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 1791254756,
      appSign: MyKeys.zegoAppSignInKey,
      userID: _myId,
      userName: _myName,
      plugins: [ZegoUIKitSignalingPlugin()],
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        //  OUTGOING SENT
        onOutgoingCallSent:
            (callID, caller, zegoCallType, callees, customData) async {
              _lastOutgoingCallId = callID;

              final data = _safeDecode(customData) ?? {};

              data["callType"] = (zegoCallType == ZegoCallType.videoCall)
                  ? "video"
                  : "audio";

              _callData[callID] = data;

              final toId =
                  (data["toId"] ?? (callees.isNotEmpty ? callees.first.id : ""))
                      .toString()
                      .trim();

              // final convId = (data["conversationId"] ?? "").toString().trim();
              // final UserModel otherUserId = Get.arguments as UserModel;
              // final convId = Messagerepository.getConversationID(
              //   otherUserId as String,
              // );
              final enums.AppCallType ct = (data["callType"] == "video")
                  ? enums.AppCallType.video
                  : enums.AppCallType.audio;

              final fromName = (data["fromName"] ?? _myName).toString().trim();
              final fromPhone = (data["fromPhone"] ?? _myPhone)
                  .toString()
                  .trim();
              final toName = (data["toName"] ?? "").toString().trim();
              final toPhone = (data["toPhone"] ?? "").toString().trim();

              await repo.CallRepo.instance.upsertCall(
                callId: callID,
                callerId: _myId,
                receiverId: toId,
                callType: ct,
                status: enums.AppCallStatus.ringing,
                callerName: fromName.isEmpty ? null : fromName,
                callerPhone: fromPhone.isEmpty ? null : fromPhone,
                receiverName: toName.isEmpty ? null : toName,
                receiverPhone: toPhone.isEmpty ? null : toPhone,
              );

              // for save to show on ui / chat screen
              // if (convId.isNotEmpty && toId.isNotEmpty) {
              //   await repo.CallRepo.instance.saveCallMessage(
              //     conversationId: convId,
              //     fromId: _myId,
              //     toId: toId,
              //     callType: ct,
              //     status: enums.AppCallStatus.ringing,
              //     timeMs: DateTime.now().millisecondsSinceEpoch,
              //     durationSec: 0,
              //     callId: callID,
              //   );
              // }
            },

        //  OUTGOING TIMEOUT
        onOutgoingCallTimeout: (callID, callees, isVideoCall) async {
          final now = DateTime.now().millisecondsSinceEpoch;
          final data = _callData[callID] ?? {};

          final toId =
              (data["toId"] ?? (callees.isNotEmpty ? callees.first.id : ""))
                  .toString()
                  .trim();

          final enums.AppCallType ct = isVideoCall
              ? enums.AppCallType.video
              : enums.AppCallType.audio;

          final fromName = (data["fromName"] ?? _myName).toString().trim();
          final fromPhone = (data["fromPhone"] ?? _myPhone).toString().trim();
          final toName = (data["toName"] ?? "").toString().trim();
          final toPhone = (data["toPhone"] ?? "").toString().trim();

          await repo.CallRepo.instance.upsertCall(
            callId: callID,
            callerId: _myId,
            receiverId: toId,
            callType: ct,
            status: enums.AppCallStatus.missed,
            endedAt: now,
            durationSec: 0,
            callerName: fromName.isEmpty ? null : fromName,
            callerPhone: fromPhone.isEmpty ? null : fromPhone,
            receiverName: toName.isEmpty ? null : toName,
            receiverPhone: toPhone.isEmpty ? null : toPhone,
          );
        },

        //  OUTGOING CANCEL BUTTON
        onOutgoingCallCancelButtonPressed: () async {
          final callID = _lastOutgoingCallId;
          if (callID == null) return;

          final now = DateTime.now().millisecondsSinceEpoch;
          final data = _callData[callID] ?? {};

          final toId = (data["toId"] ?? "").toString().trim();

          final bool isVideo = (data["callType"] ?? "audio") == "video";
          final enums.AppCallType ct = isVideo
              ? enums.AppCallType.video
              : enums.AppCallType.audio;

          final fromName = (data["fromName"] ?? _myName).toString().trim();
          final fromPhone = (data["fromPhone"] ?? _myPhone).toString().trim();
          final toName = (data["toName"] ?? "").toString().trim();
          final toPhone = (data["toPhone"] ?? "").toString().trim();

          await repo.CallRepo.instance.upsertCall(
            callId: callID,
            callerId: _myId,
            receiverId: toId,
            callType: ct,
            status: enums.AppCallStatus.canceled,
            endedAt: now,
            durationSec: 0,
            callerName: fromName.isEmpty ? null : fromName,
            callerPhone: fromPhone.isEmpty ? null : fromPhone,
            receiverName: toName.isEmpty ? null : toName,
            receiverPhone: toPhone.isEmpty ? null : toPhone,
          );
        },

        //  INCOMING CANCELED
        onIncomingCallCanceled: (callID, caller, customData) async {
          final now = DateTime.now().millisecondsSinceEpoch;

          final data = _safeDecode(customData) ?? {};
          _callData[callID] = data;

          final fromId = (data["fromId"] ?? caller.id).toString().trim();
          // final convId = (data["conversationId"] ?? "").toString().trim();

          final isVideo =
              (data["callType"]?.toString().toLowerCase() == "video");
          final enums.AppCallType ct = isVideo
              ? enums.AppCallType.video
              : enums.AppCallType.audio;

          final fromName = (data["fromName"] ?? caller.name).toString().trim();
          final fromPhone = (data["fromPhone"] ?? "").toString().trim();

          await repo.CallRepo.instance.upsertCall(
            callId: callID,
            callerId: fromId,
            receiverId: _myId,
            callType: ct,
            status: enums.AppCallStatus.canceled,
            endedAt: now,
            durationSec: 0,
            callerName: fromName.isEmpty ? null : fromName,
            callerPhone: fromPhone.isEmpty ? null : fromPhone,
            receiverName: _myName,
            receiverPhone: _myPhone.isEmpty ? null : _myPhone,
          );
        },
      ),
    );

    _inited = true;
  }

  void uninit() {
    try {
      ZegoUIKitPrebuiltCallInvitationService().uninit();
    } catch (_) {}
    _inited = false;
    _lastOutgoingCallId = null;
    _callData.clear();
  }

  Map<String, dynamic>? _safeDecode(String? customData) {
    if (customData == null) return null;
    final s = customData.trim();
    if (s.isEmpty) return null;
    try {
      final decoded = jsonDecode(s);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
