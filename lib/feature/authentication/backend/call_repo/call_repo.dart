import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:whats_app/binding/enum.dart';
import 'package:whats_app/feature/authentication/backend/call_repo/timeFormate.dart';
import 'package:whats_app/utiles/const/keys.dart';

class CallRepo extends GetxController {
  static CallRepo get instance => Get.find<CallRepo>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _safe(String? value) {
    if (value == null) return null;
    final s = value.trim();
    return s.isEmpty ? null : s;
  }

  Future<void> upsertCall({
    required String callId,
    String? callerId,
    String? receiverId,
    AppCallType? callType,
    AppCallStatus? status,

    // duration fields
    int? startedAt,
    int? connectedAt,
    int? endedAt,
    int? durationSec,

    String? receiverImage,
    String? callerImage,
    String? callerName,
    String? callerPhone,
    String? receiverName,
    String? receiverPhone,
  }) async {
    final doc = _db.collection(MyKeys.callCollection).doc(callId);
    final now = DateTime.now().millisecondsSinceEpoch;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(doc);
      final old = snap.data() ?? <String, dynamic>{};

      // keep old values if not provided
      int oldStartedAt = (old["startedAt"] is int)
          ? old["startedAt"] as int
          : 0;
      int oldConnectedAt = (old["connectedAt"] is int)
          ? old["connectedAt"] as int
          : 0;
      int oldEndedAt = (old["endedAt"] is int) ? old["endedAt"] as int : 0;
      int oldDuration = (old["durationSec"] is int)
          ? old["durationSec"] as int
          : 0;

      final data = <String, dynamic>{
        "callId": callId,
        "updatedAt": now,
        "updatedAtText": CallFormat.timeFromMillis(now),
      };

      // createdAt
      if (!snap.exists) {
        data["createdAt"] = now;
        data["createdAtText"] = CallFormat.timeFromMillis(now);
      } else if (!old.containsKey("createdAt")) {
        data["createdAt"] = now;
        data["createdAtText"] = CallFormat.timeFromMillis(now);
      }

      if (_safe(callerId) != null) data["callerId"] = callerId;
      if (_safe(receiverId) != null) data["receiverId"] = receiverId;
      if (callType != null) data["callType"] = callType.name;
      if (status != null) data["status"] = status.name;

      final finalCallerId = (data["callerId"] ?? old["callerId"] ?? "")
          .toString();
      final finalReceiverId = (data["receiverId"] ?? old["receiverId"] ?? "")
          .toString();
      if (finalCallerId.isNotEmpty && finalReceiverId.isNotEmpty) {
        data["participants"] = [finalCallerId, finalReceiverId];
      }

      //  duration fields
      final int finalStartedAt =
          startedAt ?? (oldStartedAt > 0 ? oldStartedAt : now);
      data["startedAt"] = finalStartedAt;

      final int finalConnectedAt = connectedAt ?? oldConnectedAt;
      if (finalConnectedAt > 0) {
        data["connectedAt"] = finalConnectedAt;
        data["connectedAtText"] = CallFormat.timeFromMillis(finalConnectedAt);
      }

      final int finalEndedAt = endedAt ?? oldEndedAt;
      if (finalEndedAt > 0) {
        data["endedAt"] = finalEndedAt;
        data["endedAtText"] = CallFormat.timeFromMillis(finalEndedAt);
      }

      final int finalDuration = durationSec ?? oldDuration;
      data["durationSec"] = finalDuration;

      final cImg = _safe(callerImage);
      final rImg = _safe(receiverImage);
      final cName = _safe(callerName);
      final rName = _safe(receiverName);
      final cPhone = _safe(callerPhone);
      final rPhone = _safe(receiverPhone);

      if (cImg != null) data["callerImage"] = cImg;
      if (rImg != null) data["receiverImage"] = rImg;
      if (cName != null) data["callerName"] = cName;
      if (rName != null) data["receiverName"] = rName;
      if (cPhone != null) data["callerPhone"] = cPhone;
      if (rPhone != null) data["receiverPhone"] = rPhone;

      tx.set(doc, data, SetOptions(merge: true));
    });
  }

  ///  save call status for chat screen
  // Future<void> saveCallMessage({
  //   required String conversationId,
  //   required String fromId,
  //   required String toId,
  //   required AppCallType callType,
  //   required AppCallStatus status,
  //   required int timeMs,
  //   required int durationSec,
  //   required String callId,
  // }) async {

  //   final ref = _db
  //       .collection(MyKeys.chatCollection)
  //       .doc(conversationId)
  //       .collection('messages')
  //       .doc();

  //   await ref.set({
  //     "id": ref.id,
  //     "type": "call",

  //     "callType": callType.name,
  //     "callStatus": status.name,
  //     "callId": callId,
  //     "durationSec": durationSec,

  //     "fromId": fromId,
  //     "toId": toId,

  //     "sent": timeMs,
  //     "sentText": CallFormat.timeFromMillis(timeMs),

  //     "message": callType == AppCallType.audio ? "Voice call" : "Video call",

  //     "read": "",
  //   });
  // }
}
