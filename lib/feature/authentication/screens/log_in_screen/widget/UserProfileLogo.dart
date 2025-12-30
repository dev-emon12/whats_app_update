import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:whats_app/common/widget/circular_image/MyCircularImage.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

class UserProfileLogo extends StatelessWidget {
  const UserProfileLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Obx(() {
      final pic = controller.user.value.profilePicture;

      bool isProfileAvailable = pic.isNotEmpty;

      return Hero(
        tag: "profile-photo",
        child: MyCirculerImage(
          image: isProfileAvailable ? pic : MyImage.onProfileScreen,
          height: Mysize.profile_image_height,
          width: Mysize.profile_image_width,
          borderWidth: 5.0,
          padding: 0,
          isNetworkImage: isProfileAvailable,
        ),
      );
    });
  }
}
