import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/icon/MyCircuarIcon.dart';
import 'package:whats_app/feature/authentication/screens/log_in_screen/widget/UserProfileLogo.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';

class UserProfileWithUserIcon extends StatelessWidget {
  const UserProfileWithUserIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Stack(
      alignment: Alignment.center,
      children: [
        const UserProfileLogo(),
        Positioned(
          bottom: -6,
          right: -6,
          child: MyCircularIcon(
            icon: Iconsax.edit,
            onPressed: controller.updateUserProfilePictureFromGallery,
          ),
        ),
      ],
    );
  }
}
