import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/feature/authentication/backend/call_repo/call_repo.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoService {
  ZegoService._();
  static final ZegoService instance = ZegoService._();

  final authRepo = AuthenticationRepository.instance;

  bool _inited = false;
  bool get isInited => _inited;
  final endTime = DateTime.now().millisecondsSinceEpoch;

  final Map<String, Map<String, dynamic>> _callData = {};
  String? _lastOutgoingCallId;

  Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
    required String userId,
    required String userName,
  }) async {
    final safeId = userId.trim();
    if (safeId.isEmpty) {
      debugPrint("ZEGO init blocked: userId empty");
      return;
    }

    String safeName = userName.trim();
    if (safeName.isEmpty) {
      safeName = (await authRepo.getSafeUserNameFromFirestore(safeId)).trim();
    }
    if (safeName.isEmpty) safeName = "Guest";

    if (_inited) return;

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    try {
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 1791254756,
        appSign: MyKeys.zegoAppSignInKey,
        userID: safeId,
        userName: safeName,
        plugins: [ZegoUIKitSignalingPlugin()],

        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
          onOutgoingCallSent:
              (callID, caller, callType, callees, customData) async {
                try {
                  _lastOutgoingCallId = callID;

                  final data = _safeDecode(customData);
                  if (data != null) _callData[callID] = data;

                  final fromId = (data?["fromId"] ?? caller.id).toString();
                  final toId =
                      (data?["toId"] ??
                              (callees.isNotEmpty ? callees.first.id : ""))
                          .toString();
                  final callTypeStr = (data?["callType"] ?? "video").toString();

                  await CallRepo.upsertCall(
                    callId: callID,
                    callerId: fromId,
                    receiverId: toId,
                    callType: (callTypeStr == "audio")
                        ? CallType.audio
                        : CallType.video,
                    status: CallStatus.ringing,
                    startedAt: null,
                    endedAt: null,
                    durationSec: 0,
                  );
                } catch (e) {
                  debugPrint("onOutgoingCallSent error: $e");
                }
              },

          onOutgoingCallAccepted: (callID, callee) async {
            try {
              final now = DateTime.now().millisecondsSinceEpoch;
              final data = _callData[callID];

              final fromId = (data?["fromId"] ?? safeId).toString();
              final toId = (data?["toId"] ?? callee.id).toString();
              final callTypeStr = (data?["callType"] ?? "video").toString();

              await CallRepo.upsertCall(
                callId: callID,
                callerId: fromId,
                receiverId: toId,
                callType: (callTypeStr == "audio")
                    ? CallType.audio
                    : CallType.video,
                status: CallStatus.answered,
                startedAt: now,
              );
            } catch (e) {
              debugPrint("onOutgoingCallAccepted error: $e");
            }
          },

          onOutgoingCallDeclined: (callID, callee, customData) async {
            try {
              final now = DateTime.now().millisecondsSinceEpoch;

              final data = _safeDecode(customData) ?? _callData[callID];
              if (data != null) _callData[callID] = data;

              final fromId = (data?["fromId"] ?? safeId).toString();
              final toId = (data?["toId"] ?? callee.id).toString();
              final convId = (data?["conversationId"] ?? "").toString();
              final callTypeStr = (data?["callType"] ?? "video").toString();

              final ct = (callTypeStr == "audio")
                  ? CallType.audio
                  : CallType.video;

              await CallRepo.upsertCall(
                callId: callID,
                callerId: fromId,
                receiverId: toId,
                callType: ct,
                status: CallStatus.rejected,
                endedAt: now,
                durationSec: 0,
              );

              if (convId.isNotEmpty) {
                await CallRepo.saveCallMessage(
                  conversationId: convId,
                  fromId: fromId,
                  toId: toId,
                  callType: ct,
                  status: CallStatus.rejected,
                  durationSec: 0,
                  callId: callID,
                  timeMs: endTime,
                );
              }
            } catch (e) {
              debugPrint("onOutgoingCallDeclined error: $e");
            }
          },

          onOutgoingCallTimeout: (callID, callees, isVideoCall) async {
            try {
              final now = DateTime.now().millisecondsSinceEpoch;
              final data = _callData[callID];

              final fromId = (data?["fromId"] ?? safeId).toString();
              final toId =
                  (data?["toId"] ??
                          (callees.isNotEmpty ? callees.first.id : ""))
                      .toString();
              final convId = (data?["conversationId"] ?? "").toString();

              final ct = isVideoCall ? CallType.video : CallType.audio;

              await CallRepo.upsertCall(
                callId: callID,
                callerId: fromId,
                receiverId: toId,
                callType: ct,
                status: CallStatus.missed,
                endedAt: now,
                durationSec: 0,
              );

              if (convId.isNotEmpty) {
                await CallRepo.saveCallMessage(
                  conversationId: convId,
                  fromId: fromId,
                  toId: toId,
                  callType: ct,
                  status: CallStatus.missed,
                  durationSec: 0,
                  callId: callID,
                  timeMs: endTime,
                );
              }
            } catch (e) {
              debugPrint("onOutgoingCallTimeout error: $e");
            }
          },

          onOutgoingCallCancelButtonPressed: () async {
            try {
              final callID = _lastOutgoingCallId;
              if (callID == null) return;

              final now = DateTime.now().millisecondsSinceEpoch;
              final data = _callData[callID];

              final fromId = (data?["fromId"] ?? safeId).toString();
              final toId = (data?["toId"] ?? "").toString();
              final convId = (data?["conversationId"] ?? "").toString();
              final callTypeStr = (data?["callType"] ?? "video").toString();
              final ct = (callTypeStr == "audio")
                  ? CallType.audio
                  : CallType.video;

              await CallRepo.upsertCall(
                callId: callID,
                callerId: fromId,
                receiverId: toId,
                callType: ct,
                status: CallStatus.canceled,
                endedAt: now,
                durationSec: 0,
              );

              if (convId.isNotEmpty && toId.isNotEmpty) {
                await CallRepo.saveCallMessage(
                  conversationId: convId,
                  fromId: fromId,
                  toId: toId,
                  callType: ct,
                  status: CallStatus.canceled,
                  durationSec: 0,
                  callId: callID,
                  timeMs: endTime,
                );
              }
            } catch (e) {
              debugPrint("onOutgoingCallCancelButtonPressed error: $e");
            }
          },

          onIncomingCallCanceled: (callID, caller, customData) async {
            try {
              final now = DateTime.now().millisecondsSinceEpoch;

              final data = _safeDecode(customData);
              if (data != null) _callData[callID] = data;

              final fromId = (data?["fromId"] ?? caller.id).toString();
              final toId = (data?["toId"] ?? safeId).toString();
              final convId = (data?["conversationId"] ?? "").toString();
              final callTypeStr = (data?["callType"] ?? "video").toString();
              final ct = (callTypeStr == "audio")
                  ? CallType.audio
                  : CallType.video;

              await CallRepo.upsertCall(
                callId: callID,
                callerId: fromId,
                receiverId: toId,
                callType: ct,
                status: CallStatus.canceled,
                endedAt: now,
                durationSec: 0,
              );

              if (convId.isNotEmpty) {
                await CallRepo.saveCallMessage(
                  conversationId: convId,
                  fromId: fromId,
                  toId: toId,
                  callType: ct,
                  status: CallStatus.canceled,
                  durationSec: 0,
                  callId: callID,
                  timeMs: endTime,
                );
              }
            } catch (e) {
              debugPrint("onIncomingCallCanceled error: $e");
            }
          },
        ),
      );

      _inited = true;
      debugPrint("ZEGO init OK: $safeId / $safeName");
    } catch (e) {
      _inited = false;
      debugPrint("ZEGO init failed: $e");
    }
  }

  void uninit() {
    try {
      ZegoUIKitPrebuiltCallInvitationService().uninit();
    } catch (_) {}
    _inited = false;
    _callData.clear();
    _lastOutgoingCallId = null;
  }

  Map<String, dynamic>? _safeDecode(String? customData) {
    if (customData == null) return null;
    final s = customData.trim();
    if (s.isEmpty) return null;
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}
