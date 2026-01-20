import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class Calls_list extends StatelessWidget {
  const Calls_list({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);
    final myId = FirebaseAuth.instance.currentUser!.uid;

    final stream = FirebaseFirestore.instance
        .collection("calls")
        .where(
          Filter.or(
            Filter("callerId", isEqualTo: myId),
            Filter("receiverId", isEqualTo: myId),
          ),
        )
        .orderBy("createdAt", descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(child: Text("No calls yet"));
        }

        final docs = snap.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.only(top: 8),
          separatorBuilder: (_, __) => SizedBox(height: Mysize.xs),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data();

            final callerId = (d["callerId"] ?? "").toString();
            final receiverId = (d["receiverId"] ?? "").toString();

            final isOutgoing = callerId == myId;

            final otherName = isOutgoing
                ? _safeText(d["receiverName"], receiverId)
                : _safeText(d["callerName"], callerId);

            final otherPhone = isOutgoing
                ? _safeText(d["receiverPhone"], "")
                : _safeText(d["callerPhone"], "");

            final status = (d["status"] ?? "").toString().toLowerCase();
            final isMissed = status == "missed";

            final callType = (d["callType"] ?? "audio")
                .toString()
                .toLowerCase();
            final isVideo = callType == "video";

            final directionIcon = isOutgoing
                ? Icons.call_made
                : Icons.call_received;

            final timeMs = d["endedAt"] ?? d["createdAt"] ?? d["updatedAt"];
            final timeText = _formatWhatsAppTime(timeMs);

            final subtitleText = otherPhone.isNotEmpty
                ? "$timeText • $otherPhone"
                : timeText;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(MyImage.onProfileScreen),
              ),

              //  Name
              title: Text(
                otherName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              //  WhatsApp style subtitle
              subtitle: Row(
                children: [
                  Icon(
                    directionIcon,
                    size: 16,
                    color: isMissed ? Colors.redAccent : Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subtitleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isDark
                            ? Colors.white70
                            : Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),

              //  WhatsApp right icon
              trailing: Icon(
                isVideo ? Icons.videocam : Icons.call,
                color: isMissed
                    ? Colors.redAccent
                    : (isDark ? Colors.white : Mycolors.textPrimary),
              ),
            );
          },
        );
      },
    );
  }

  String _safeText(dynamic v, String fallback) {
    final s = (v ?? "").toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _formatWhatsAppTime(dynamic value) {
    final ms = _toMillis(value);
    if (ms == 0) return "";

    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    final diffDays = today.difference(date).inDays;

    final timePart = DateFormat("hh:mm a").format(dt);

    if (diffDays == 0) return "Today, $timePart";
    if (diffDays == 1) return "Yesterday, $timePart";
    return "${DateFormat("dd MMM").format(dt)}, $timePart";
  }

  int _toMillis(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    return 0;
  }
}
