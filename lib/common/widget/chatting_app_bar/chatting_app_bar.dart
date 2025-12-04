import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatarImage,
    this.onBack,
    this.onProfileTap,
    this.onVideoCall,
    this.onVoiceCall,
    this.onMore,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 70,
  });

  final String name;
  final String? subtitle;
  final ImageProvider? avatarImage;

  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final VoidCallback? onVideoCall;
  final VoidCallback? onVoiceCall;
  final VoidCallback? onMore;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);

    return AppBar(
      backgroundColor: isDark ? Mycolors.dark : Mycolors.light,
      foregroundColor: isDark ? Mycolors.light : Mycolors.dark,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leadingWidth: 50,
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
              radius: 25,
              backgroundImage:
                  avatarImage ?? AssetImage(MyImage.onProfileScreen),
            ),
          ),
          const SizedBox(width: 12),
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
                      // If user is online
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
                      // Otherwise show marquee for long text
                      return SizedBox(
                        height: 20,
                        child: Marquee(
                          text: subtitle!,
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: isDark
                                    ? Mycolors.light
                                    : Mycolors.dark.withOpacity(0.7),
                              ),
                          blankSpace: 30,
                          velocity: 20.0,
                          pauseAfterRound: const Duration(seconds: 2),
                          numberOfRounds: 2,
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
        IconButton(
          onPressed: onVideoCall,
          icon: Icon(
            Icons.videocam_outlined,
            color: isDark ? Mycolors.light : Mycolors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: onVoiceCall,
          icon: Icon(
            Icons.call_outlined,
            color: isDark ? Mycolors.light : Mycolors.textPrimary,
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
