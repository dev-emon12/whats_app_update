import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:marquee/marquee.dart';
import 'package:whats_app/common/widget/permision_handeler/permission_handeler.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

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

    // ✅ Correct type for ZegoSendCallInvitationButton
    final invitees = [
      ZegoUIKitUser(id: otherUser.id, name: otherUser.username),
    ];

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
        //  VOICE CALL
        GestureDetector(
          onTap: () {
            Get.put(PermissionHandeler());
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: FittedBox(
              fit: BoxFit.scaleDown,

              child: ZegoSendCallInvitationButton(
                resourceID: "ZegoCall",
                isVideoCall: false,
                invitees: invitees,
                icon: ButtonIcon(
                  icon: Icon(
                    Icons.call_outlined,
                    color: isDark ? Mycolors.light : Mycolors.textPrimary,
                  ),
                ),
                buttonSize: const Size(44, 44),
                iconSize: const Size(28, 28),
                verticalLayout: false,
                text: null,
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        //  VIDEO CALL
        GestureDetector(
          onTap: () {
            Get.put(PermissionHandeler());
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ZegoSendCallInvitationButton(
                resourceID: "ZegoCall",
                isVideoCall: true,
                invitees: invitees,
                icon: ButtonIcon(
                  icon: Icon(
                    Icons.videocam_outlined,
                    color: isDark ? Mycolors.light : Mycolors.textPrimary,
                  ),
                ),
                buttonSize: const Size(44, 44),
                iconSize: const Size(28, 28),
                verticalLayout: false,
                text: null,
              ),
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
