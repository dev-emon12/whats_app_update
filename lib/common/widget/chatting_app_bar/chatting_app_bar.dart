import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:whats_app/feature/Chatting_screen/widget/callPage.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatarImage,
    required this.otherUser,
    this.onBack,
    this.onProfileTap,
    this.onMore,
    this.height = 70,
  });

  final String name;
  final String? subtitle;
  final ImageProvider? avatarImage;
  final UserModel otherUser;

  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMore;

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  static String conversationId(String a, String b) {
    final list = [a, b]..sort();
    return "${list[0]}_${list[1]}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);

    final me = FirebaseAuth.instance.currentUser;
    final myId = me?.uid ?? "";
    final callId = "call_${myId}_${DateTime.now().millisecondsSinceEpoch}";

    // Zego invitees
    final invitees = [
      ZegoUIKitUser(id: otherUser.id, name: otherUser.username),
    ];

    final convId = conversationId(myId, otherUser.id);

    final audioCallId = "call_${myId}_${DateTime.now().millisecondsSinceEpoch}";
    final audioCustomData = jsonEncode({
      "conversationId": convId,
      "fromId": myId,
      "toId": otherUser.id,
      "callType": "audio",
    });

    final videoCallId = "call_${myId}_${DateTime.now().millisecondsSinceEpoch}";
    final videoCustomData = jsonEncode({
      "conversationId": convId,
      "fromId": myId,
      "toId": otherUser.id,
      "callType": "video",
    });

    return AppBar(
      backgroundColor: isDark ? Mycolors.dark : Mycolors.light,
      foregroundColor: isDark ? Mycolors.light : Mycolors.dark,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leadingWidth: 35,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Mycolors.light : Mycolors.dark,
        ),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 22,
              backgroundImage:
                  avatarImage ?? const AssetImage(MyImage.onProfileScreen),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: isDark ? Mycolors.light : Mycolors.dark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Builder(
                    builder: (_) {
                      if (subtitle!.toLowerCase() == "online") {
                        return Text(
                          "Online",
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: isDark
                                    ? Mycolors.light
                                    : Mycolors.dark.withOpacity(0.7),
                              ),
                        );
                      }
                      return SizedBox(
                        height: 18,
                        child: Marquee(
                          text: subtitle!,
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: isDark
                                    ? Mycolors.light
                                    : Mycolors.dark.withOpacity(0.7),
                              ),
                          blankSpace: 30,
                          velocity: 20,
                          pauseAfterRound: const Duration(seconds: 2),
                          numberOfRounds: 2,
                          startAfter: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        //  audio call button
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {
            final me = FirebaseAuth.instance.currentUser!;
            final myId = me.uid;

            final callId =
                "call_${myId}_${DateTime.now().millisecondsSinceEpoch}";

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CallPage(
                  otherUser: otherUser,
                  isVideoCall: true,
                  callId: callId,
                ),
              ),
            );
          },
        ),

        // vide call button
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            final me = FirebaseAuth.instance.currentUser!;
            final myId = me.uid;

            final callId =
                "call_${myId}_${DateTime.now().millisecondsSinceEpoch}";

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CallPage(
                  otherUser: otherUser,
                  isVideoCall: false,
                  callId: callId,
                ),
              ),
            );
          },
        ),

        IconButton(
          onPressed: onMore,
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Mycolors.light : Mycolors.textPrimary,
          ),
        ),
      ],
    );
  }
}
