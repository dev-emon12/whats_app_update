import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:whats_app/common/widget/ZegoCallBtn/ZegoCallBtn.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/otherUserScreen.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

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

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);

    return AppBar(
      toolbarHeight: height,
      backgroundColor: isDark ? Mycolors.dark : Mycolors.light,
      foregroundColor: isDark ? Mycolors.light : Mycolors.dark,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leadingWidth: 45,

      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Mycolors.light : Mycolors.dark,
        ),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),

      title: InkWell(
        onTap: () => Get.to(OtherUserProfile(), arguments: otherUser),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    avatarImage ?? const AssetImage(MyImage.onProfileScreen),
              ),
              SizedBox(width: 10),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                              style: Theme.of(context).textTheme.labelSmall!
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
        ),
      ),

      actions: [
        SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: ZegoCallInvitationButton(
              otherUser: otherUser,
              isVideo: true,
              icon: Icons.videocam,
              text: 'video',
              color: isDark ? Mycolors.light : Mycolors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 6),
        SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: ZegoCallInvitationButton(
              otherUser: otherUser,
              isVideo: false,
              icon: Icons.call,
              text: 'audio',
              color: isDark ? Mycolors.light : Mycolors.textPrimary,
            ),
          ),
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
