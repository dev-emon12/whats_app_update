import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.message,
    this.onLongPress,
    this.isSelected = false,
  });

  final Map<String, dynamic> message;

  final VoidCallback? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final String myId = FirebaseAuth.instance.currentUser!.uid;
    final String fromId = (message['fromId'] ?? '').toString().trim();
    final bool isSentByMe = fromId == myId;

    final String type = (message['type'] ?? '').toString().trim().toLowerCase();
    final String msg = (message['message'] ?? message['msg'] ?? '').toString();

    final int timeMs = _toMillis(
      message['sent'] ?? message['time'] ?? message['createdAt'],
    );

    final bool isSeen = (message['read'] ?? '').toString().isNotEmpty;
    final bool isImage = type == 'image';

    final bool isCall =
        type == 'call' ||
        message['callId'] != null ||
        message['callType'] != null ||
        message['callStatus'] != null;

    // CALL FIELDS
    final String rawCallType =
        (message['callType'] ?? message['call_type'] ?? 'audio')
            .toString()
            .trim()
            .toLowerCase();

    final bool isVideo = rawCallType == 'video';
    final String callTypeLabel = isVideo ? "Video" : "Voice";

    final String callStatus = (message['callStatus'] ?? message['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final int durationSec = _toInt(
      message['durationSec'] ?? message['duration'],
    );

    final bool isMissed = callStatus == 'missed';
    final bool isRejected = callStatus == 'rejected';
    final bool isCanceled = callStatus == 'canceled';
    final bool isAnswered = callStatus == 'answered';
    final bool isEnded = callStatus == 'ended' || isAnswered;

    final IconData callIcon = isVideo ? Icons.videocam : Icons.call;

    String callTitle;
    Color callColor;

    if (isMissed) {
      callTitle = "Missed $callTypeLabel call";
      callColor = Colors.redAccent;
    } else if (isRejected) {
      callTitle = "Declined $callTypeLabel call";
      callColor = Colors.redAccent;
    } else if (isCanceled) {
      callTitle = "Canceled $callTypeLabel call";
      callColor = Colors.white;
    } else {
      callTitle = "$callTypeLabel call";
      callColor = Colors.white;
    }

    final String callSub = (isEnded && durationSec > 0)
        ? _formatDurationClock(durationSec)
        : "";

    final Color bubbleColor = isSelected
        ? Colors.blueGrey
        : (isSentByMe
              ? const Color.fromARGB(255, 119, 170, 122)
              : const Color.fromARGB(255, 79, 76, 76));

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: EdgeInsets.symmetric(
            vertical: (isImage || isCall) ? 8 : 10,
            horizontal: (isImage || isCall) ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isSentByMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isSentByMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: isSentByMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    msg,
                    width: 280,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.white70),
                  ),
                )
              else if (isCall)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(callIcon, size: 18, color: callColor),
                    SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            callTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Mycolors.light,
                                  fontSize: 15,
                                  fontWeight: (isMissed || isRejected)
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                          ),
                          if (callSub.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                callSub,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Text(
                  msg.isEmpty ? " " : msg,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Mycolors.light,
                    fontSize: 15,
                  ),
                ),

              SizedBox(height: 4),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Messagerepository.getFormattedTime(
                      context: context,
                      time: timeMs.toString(),
                    ),
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  SizedBox(width: Mysize.sm),
                  if (isSentByMe) ...[
                    SizedBox(width: 5),
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: isSeen ? Colors.blue : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.floor();
    return int.tryParse(v.toString()) ?? 0;
  }

  int _toMillis(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    return int.tryParse(v.toString()) ?? 0;
  }

  String _formatDurationClock(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}
