import 'package:flutter/material.dart';

class CallMessageBubble extends StatelessWidget {
  const CallMessageBubble({super.key, required this.msg, required this.isMe});

  final Map<String, dynamic> msg;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final callType = (msg["callType"] ?? "audio").toString();
    final callStatus = (msg["callStatus"] ?? "").toString();
    final durationSec = _toInt(msg["durationSec"]);

    final icon = callType == "video" ? Icons.videocam : Icons.call;

    final statusText = _statusText(callStatus);
    final durationText = (callStatus == "ended" && durationSec > 0)
        ? _formatDuration(durationSec)
        : "";

    final text = durationText.isEmpty
        ? statusText
        : "$statusText • $durationText";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.green.shade600 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isMe ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.floor();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String _statusText(String status) {
    switch (status) {
      case "ended":
        return "Call ended";
      case "missed":
        return "Missed call";
      case "canceled":
        return "Canceled call";
      case "rejected":
        return "Declined call";
      case "ringing":
        return "Calling…";
      case "answered":
        return "Answered";
      default:
        return "Call";
    }
  }
}
