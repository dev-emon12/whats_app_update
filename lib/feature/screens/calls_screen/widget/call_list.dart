import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/common/widget/ZegoCallBtn/ZegoCallBtn.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/call_repo/timeFormate.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';

class Calls_list extends StatelessWidget {
  const Calls_list({super.key});

  @override
  Widget build(BuildContext context) {
    final myId = FirebaseAuth.instance.currentUser!.uid;

    final stream = FirebaseFirestore.instance
        .collection("calls")
        .where("participants", arrayContains: myId)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              color: Mycolors.success,
            ),
          );
        }

        if (snap.hasError) {
          return Center(child: Text("Firestore error:\n${snap.error}"));
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(child: Text("No calls yet..."));
        }

        final docs = [...snap.data!.docs];
        docs.sort((a, b) {
          int getTime(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final d = doc.data();
            final v = d["updatedAt"] ?? d["createdAt"] ?? d["endedAt"] ?? 0;
            return (v is int) ? v : int.tryParse(v.toString()) ?? 0;
          }

          return getTime(b).compareTo(getTime(a));
        });

        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 5),
            itemCount: docs.length,
            separatorBuilder: (_, __) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final d = docs[index].data();

              final callerId = (d["callerId"] ?? "").toString();
              final receiverId = (d["receiverId"] ?? "").toString();
              final isOutgoing = callerId == myId;

              final otherName = isOutgoing
                  ? _safeText(d["receiverName"], receiverId)
                  : _safeText(d["callerName"], callerId);

              final status = (d["status"] ?? "").toString().toLowerCase();
              final callType = (d["callType"] ?? "audio")
                  .toString()
                  .toLowerCase();
              final isVideo = callType == "video";

              final isMissed = status == "missed";
              final isRejected = status == "rejected";

              final directionIcon = isOutgoing
                  ? Icons.call_made
                  : Icons.call_received;
              final directionColor = (isMissed || isRejected)
                  ? Colors.redAccent
                  : Colors.green;

              final timeMs = d["endedAt"] ?? d["createdAt"] ?? d["updatedAt"];
              final timeText = CallFormat.whatsappTime(timeMs);
              final subtitle = "${_statusText(status)} • $timeText";

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),

                onTap: () {
                  final user = _userFromCall(d, isOutgoing);
                  showModalBottomSheet(
                    context: context,
                    useSafeArea: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) {
                      return Padding(
                        padding: MyPadding.screenPadding,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // AUDIO CALL
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ZegoCallInvitationButton(
                                otherUser: user,
                                isVideo: false,
                                icon: Icons.call,
                                text: "audio",
                                size: 20,
                              ),
                              title: Text(
                                "Audio call",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text("Call using voice"),
                            ),

                            SizedBox(height: 10),

                            // VIDEO CALL
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ZegoCallInvitationButton(
                                otherUser: user,
                                isVideo: true,
                                icon: Icons.videocam,
                                text: "video",
                                size: 20,
                              ),
                              title: Text(
                                "Video call",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text("Call with video"),
                            ),

                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  );
                },

                leading: CircleAvatar(
                  radius: 24,
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : "?",
                  ),
                ),

                title: Text(
                  otherName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),

                subtitle: Row(
                  children: [
                    Icon(directionIcon, size: 16, color: directionColor),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                trailing: Icon(
                  isVideo ? Icons.videocam : Icons.call,
                  color: (isMissed || isRejected)
                      ? Colors.redAccent
                      : Colors.green,
                ),
              );
            },
          ),
        );
      },
    );
  }

  UserModel _userFromCall(Map<String, dynamic> d, bool isOutgoing) {
    return UserModel(
      id: isOutgoing ? d["receiverId"] : d["callerId"],
      username: isOutgoing
          ? (d["receiverName"] ?? "User")
          : (d["callerName"] ?? "User"),
      phoneNumber: isOutgoing ? d["receiverPhone"] : d["callerPhone"],
      profilePicture: "",
      email: '',
      about: '',
      createdAt: '',
      isOnline: true,
      pushToken: '',
      lastActive: '',
    );
  }

  String _safeText(dynamic v, String fallback) {
    final s = (v ?? "").toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _statusText(String status) {
    switch (status) {
      case "missed":
        return "Missed";
      case "rejected":
        return "Declined";
      case "canceled":
        return "Canceled";
      case "ended":
        return "Call";
      case "answered":
        return "Answered";
      case "ringing":
        return "Calling…";
      default:
        return "Call";
    }
  }
}
