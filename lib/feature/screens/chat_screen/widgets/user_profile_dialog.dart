import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/ZegoCallBtn/ZegoCallBtn.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/otherUserScreen.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

void showUesrDialog(context, UserModel user) {
  final isDark = MyHelperFunction.isDarkMode(context);
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: isDark ? Mycolors.light : Mycolors.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          user.username,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: isDark ? Mycolors.dark : Mycolors.light,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: Mysize.alert_dialog_image_height,
          width: Mysize.alert_dialog_image_width,
          child: Hero(
            tag: user.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: user.profilePicture.isNotEmpty
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: user.profilePicture,
                      errorWidget: (c, url, err) =>
                          CircleAvatar(child: Icon(Iconsax.user)),
                    )
                  : Image.asset(MyImage.onProfileScreen, fit: BoxFit.cover),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () =>
                    Get.off(() => ChattingScreen(), arguments: user),
                icon: Icon(Iconsax.message, color: Mycolors.buttonPrimary),
              ),
              ZegoCallInvitationButton(
                otherUser: user,
                isVideo: true,
                icon: Iconsax.video,
                text: 'video',
                color: Mycolors.buttonPrimary,
                size: 20,
              ),
              ZegoCallInvitationButton(
                otherUser: user,
                isVideo: false,
                icon: Iconsax.call,
                text: 'audio',
                color: Mycolors.buttonPrimary,
                size: 20,
              ),
              IconButton(
                onPressed: () => Get.to(OtherUserProfile(), arguments: user),
                icon: Icon(Icons.error, color: Mycolors.buttonPrimary),
              ),
            ],
          ),
        ],
      );
    },
  );
}
