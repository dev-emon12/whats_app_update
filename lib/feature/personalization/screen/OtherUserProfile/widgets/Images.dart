import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/common/widget/shimmerEffect/shimmerEffect.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/widgets/ImagePreview.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/widgets/ShimmerEffectForImage.dart';
import 'package:whats_app/utiles/const/keys.dart';

class ChatImages extends StatelessWidget {
  const ChatImages({super.key, required this.otherUserId});

  final String otherUserId;

  String _conversationId(String otherId) {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    return myId.hashCode <= otherId.hashCode
        ? '${myId}_$otherId'
        : '${otherId}_$myId';
  }

  @override
  Widget build(BuildContext context) {
    final cid = _conversationId(otherUserId);

    final stream = FirebaseFirestore.instance
        .collection(MyKeys.chatCollection)
        .doc(cid)
        .collection(MyKeys.messageCollection)
        .where("type", isEqualTo: "image")
        .orderBy("sent", descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerHorizontalList(
            count: 6,
            height: 160,
            itemWidth: 150,
            itemHeight: 160,
          );
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text("No Images...");
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            separatorBuilder: (_, __) => SizedBox(width: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final url = (data["msg"] ?? "").toString().trim();

              if (url.isEmpty) return SizedBox.shrink();

              // show Image
              return ImagePreview(url: url);
            },
          ),
        );
      },
    );
  }
}
