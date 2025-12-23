import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }

enum CallDirection { incoming, outgoing }

enum CallStatus { ringing, answered, ended, missed }

class CallRepo {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save call log: calls/{callId}
  static Future<void> saveCallLog({
    required String callId,
    required String callerId,
    required String receiverId,
    required CallType callType,
    required CallDirection direction,
    required CallStatus status,
    required int startedAt,
    required int endedAt,
    required int durationSec,
  }) async {
    await _db.collection("calls").doc(callId).set({
      "callId": callId,
      "callerId": callerId,
      "receiverId": receiverId,
      "callType": callType.name,
      "direction": direction.name,
      "status": status.name,
      "startedAt": startedAt,
      "endedAt": endedAt,
      "durationSec": durationSec,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  // Save call as chat message: chats/{conversationId}/messages/{msgId}
  static Future<void> saveCallMessage({
    required String conversationId,
    required String fromId,
    required String toId,
    required CallType callType,
    required CallStatus status,
    required int time,
    required int durationSec,
    required String callId,
  }) async {
    final ref = _db
        .collection("chats")
        .doc(conversationId)
        .collection("messages")
        .doc();

    final text = callType == CallType.audio ? "Audio call" : "Video call";

    await ref.set({
      "id": ref.id,
      "type": "call",
      "callType": callType.name, // audio/video
      "callStatus": status.name, // missed/ended/answered...
      "callId": callId,
      "fromId": fromId,
      "toId": toId,
      "sent": time.toString(), // keep same format as your app
      "durationSec": durationSec,
      "message": text, // ✅ MessageCard should show this
      "read": "", // optional
    });
  }
}
