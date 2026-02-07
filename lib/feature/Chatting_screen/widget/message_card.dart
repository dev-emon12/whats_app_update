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

    final Map<String, dynamic> deletedBy = message['deletedBy'] ?? {};
    if (deletedBy[myId] == true) {
      return SizedBox.shrink();
    }

    final String fromId = (message['fromId'] ?? '').toString().trim();
    final bool isSentByMe = fromId == myId;

    final String type = (message['type'] ?? '').toString().trim().toLowerCase();
    final String msg = (message['message'] ?? message['msg'] ?? '').toString();

    final int timeMs = _toMillis(
      message['sent'] ?? message['time'] ?? message['createdAt'],
    );

    final bool isSeen = (message['read'] ?? '').toString().isNotEmpty;
    final bool isImage = type == 'image';

    final Color bubbleColor = isSelected
        ? const Color.fromARGB(184, 144, 35, 35)
        : (isSentByMe ? Mycolors.success : Color.fromARGB(255, 79, 76, 76));

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: EdgeInsets.symmetric(
            vertical: isImage ? 8 : 10,
            horizontal: isImage ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isSentByMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isSentByMe ? Radius.zero : Radius.circular(12),
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
                        Icon(Icons.broken_image, color: Colors.white70),
                  ),
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

  int _toMillis(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    return int.tryParse(v.toString()) ?? 0;
  }
}
