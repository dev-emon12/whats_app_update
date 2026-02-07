import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:whats_app/binding/enum.dart';
import 'package:whats_app/feature/authentication/backend/call_repo/timeFormate.dart';
import 'package:whats_app/utiles/const/keys.dart';

class CallRepo extends GetxController {
  static CallRepo get instance => Get.find<CallRepo>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _safe(String? v) {
    if (v == null) return null;
    final s = v.trim();
    return s.isEmpty ? null : s;
  }

  // save call status in db
  Future<void> upsertCall({
    required String callId,
    required String callerId,
    required String receiverId,
    required AppCallType callType,
    required AppCallStatus status,
    String? callerName,
    String? callerPhone,
    String? receiverName,
    String? receiverPhone,
    int? startedAt,
    int? endedAt,
    int? durationSec,
  }) async {
    final doc = _db.collection(MyKeys.callCollection).doc(callId);
    final now = DateTime.now().millisecondsSinceEpoch;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(doc);

      final data = <String, dynamic>{
        "callId": callId,
        "callerId": callerId,
        "receiverId": receiverId,
        "participants": [callerId, receiverId],

        "callType": callType.name,
        "status": status.name,

        "startedAt": startedAt,
        "endedAt": endedAt,
        "durationSec": durationSec ?? 0,

        "updatedAt": now,
        "updatedAtText": CallFormat.timeFromMillis(now),
      };

      if (!snap.exists) {
        data["createdAt"] = now;
      } else if (!(snap.data() ?? {}).containsKey("createdAt")) {
        data["createdAt"] = now;
      }

      data["createdAtText"] = CallFormat.timeFromMillis(data["createdAt"]);

      if (endedAt != null) {
        data["endedAtText"] = CallFormat.timeFromMillis(endedAt);
      }

      final cn = _safe(callerName);
      final cp = _safe(callerPhone);
      final rn = _safe(receiverName);
      final rp = _safe(receiverPhone);

      if (cn != null) data["callerName"] = cn;
      if (cp != null) data["callerPhone"] = cp;
      if (rn != null) data["receiverName"] = rn;
      if (rp != null) data["receiverPhone"] = rp;

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
