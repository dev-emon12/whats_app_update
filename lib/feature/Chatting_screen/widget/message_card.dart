import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message});

  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);

    // message text
    final String msg = (message['message'] ?? message['msg'] ?? '').toString();

    final int timeMs = _toMillis(
      message['sent'] ?? message['time'] ?? message['createdAt'],
    );

    final bool isSeen = (message['read'] ?? '').toString().isNotEmpty;

    final String myId = FirebaseAuth.instance.currentUser!.uid;
    final String fromId = (message['fromId'] ?? '').toString();
    final bool isSentByMe = fromId == myId;

    final String type = (message['type'] ?? 'text').toString();
    final bool isImage = type == 'image';
    final bool isCall = type == 'call';

    // CALL fields
    final String rawCallType = (message['callType'] ?? 'audio')
        .toString()
        .toLowerCase();
    final bool isVideo = rawCallType == 'video';
    final String callTypeLabel = isVideo ? "Video" : "Voice";

    final String callStatus = (message['callStatus'] ?? '')
        .toString()
        .toLowerCase();

    final int durationSec = _toInt(message['durationSec']);

    final bool isMissed = callStatus == 'missed';
    final bool isRejected = callStatus == 'rejected';
    final bool isCanceled = callStatus == 'canceled';
    final bool isEnded = callStatus == 'ended';

    final IconData callIcon = isVideo ? Icons.videocam : Icons.call;

    String callTitle;
    if (isMissed) {
      callTitle = "Missed $callTypeLabel call";
    } else if (isRejected) {
      callTitle = "Declined $callTypeLabel call";
    } else if (isCanceled) {
      callTitle = "Canceled $callTypeLabel call";
    } else {
      callTitle = "$callTypeLabel call";
    }

    String callSubtitle = "";
    if (isEnded && durationSec > 0) {
      callSubtitle = _formatDurationClock(durationSec);
    }

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: EdgeInsets.symmetric(
          vertical: (isImage || isCall) ? 6 : 10,
          horizontal: (isImage || isCall) ? 8 : 14,
        ),
        decoration: BoxDecoration(
          color: isSentByMe
              ? const Color.fromARGB(255, 119, 170, 122)
              : const Color.fromARGB(255, 79, 76, 76),
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
            // ---------- CONTENT ----------
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  msg,
                  width: 280,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingprogress) {
                    if (loadingprogress == null) return child;
                    return Container(
                      width: 220,
                      height: 220,
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white70),
                ),
              )
            else if (isCall)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    callIcon,
                    size: 18,
                    color: (isMissed || isRejected)
                        ? Colors.redAccent
                        : Colors.white,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          callTitle,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Mycolors.light,
                                fontSize: 15,
                                fontWeight: (isMissed || isRejected)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                        if (callSubtitle.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              callSubtitle,
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
                msg,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Mycolors.light,
                  fontSize: 15,
                ),
              ),

            const SizedBox(height: 4),

            // ---------- TIME + TICK ----------
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Messagerepository.getFormattedTime(
                    context: context,
                    time: timeMs.toString(),
                  ),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                SizedBox(width: Mysize.sm),
                Text(
                  Messagerepository.getLastMessageday(
                    context: context,
                    time: timeMs.toString(),
                  ),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                if (isSentByMe) ...[
                  const SizedBox(width: 5),
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
    );
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.floor();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  int _toMillis(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    return 0;
  }

  String _formatDurationClock(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}
