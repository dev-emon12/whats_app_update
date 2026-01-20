import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }

enum CallStatus { ringing, answered, ended, missed, rejected, canceled }

class CallRepo {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String conversationId(String a, String b) {
    final list = [a, b]..sort();
    return "${list[0]}_${list[1]}";
  }

  static Future<void> upsertCall({
    required String callId,
    required String callerId,
    required String receiverId,
    required CallType callType,
    required CallStatus status,
    String? callerName,
    String? callerPhone,
    String? receiverName,
    String? receiverPhone,
    int? startedAt,
    int? endedAt,
    int? durationSec,
  }) async {
    final doc = _db.collection("calls").doc(callId);
    final now = DateTime.now().millisecondsSinceEpoch;

    final snap = await doc.get();

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
    };

    if (!snap.exists) data["createdAt"] = now;

    if (_safe(callerName) != null) data["callerName"] = _safe(callerName);
    if (_safe(callerPhone) != null) data["callerPhone"] = _safe(callerPhone);
    if (_safe(receiverName) != null) data["receiverName"] = _safe(receiverName);
    if (_safe(receiverPhone) != null)
      data["receiverPhone"] = _safe(receiverPhone);

    await doc.set(data, SetOptions(merge: true));
  }

  static String? _safe(String? v) {
    if (v == null) return null;
    final s = v.trim();
    return s.isEmpty ? null : s;
  }

  static Future<void> saveCallMessage({
    required String conversationId,
    required String fromId,
    required String toId,
    required CallType callType,
    required CallStatus status,
    required int timeMs,
    required int durationSec,
    required String callId,
  }) async {
    final ref = _db
        .collection("chats")
        .doc(conversationId)
        .collection("messages")
        .doc(callId);

    // message text
    final typeLabel = callType == CallType.video ? "video" : "voice";
    String text;

    if (status == CallStatus.missed) {
      text = "Missed $typeLabel call";
    } else if (status == CallStatus.rejected) {
      text = "Declined $typeLabel call";
    } else if (status == CallStatus.canceled) {
      text = "Canceled $typeLabel call";
    } else {
      text = "${typeLabel[0].toUpperCase()}${typeLabel.substring(1)} call";
    }

    await ref.set({
      "id": callId,
      "type": "call",
      "callType": callType.name,
      "callStatus": status.name,
      "callId": callId,
      "fromId": fromId,
      "toId": toId,
      "sent": timeMs,
      "durationSec": durationSec,
      "message": text,
      "read": "",
    }, SetOptions(merge: true));
  }
}
