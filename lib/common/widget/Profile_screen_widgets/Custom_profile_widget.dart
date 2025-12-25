import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/show_profile_in_big_screen.dart';
import 'package:whats_app/utiles/theme/const/image.dart';

class Custom_profile_widget extends StatelessWidget {
  const Custom_profile_widget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return GestureDetector(
      onTap: () {
        final user = controller.user.value;
        Get.to(() => OnScreenProfile(), arguments: user);
      },
      child: Obx(() {
        final user = controller.user.value;

        return Hero(
          tag: "profile-photo",
          child: ClipRRect(
            key: ValueKey(user.profilePicture),
            borderRadius: BorderRadius.circular(1000),
            child: user.profilePicture.isNotEmpty
                ? CachedNetworkImage(
                    height: 225,
                    width: 225,
                    fit: BoxFit.cover,
                    imageUrl: user.profilePicture,
                    errorWidget: (c, url, err) =>
                        CircleAvatar(child: Icon(Iconsax.user)),
                  )
                : Image.asset(MyImage.onProfileScreen, fit: BoxFit.cover),
          ),
        );
      }),
    );
  }
}
