import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/circular_image/MyCircularImage.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/widgets/openImage.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);
    final UserModel user = Get.arguments as UserModel;
    final pic = user.profilePicture.toString();
    bool isProfileAvailable = pic.isNotEmpty;

    return Column(
      children: [
        // User Image
        GestureDetector(
          onTap: () => Get.to(() => OpenProfile(), arguments: user),
          child: Hero(
            tag: user.id,
            child: MyCirculerImage(
              image: isProfileAvailable ? pic : MyImage.onProfileScreen,
              height: Mysize.profile_image_height,
              width: Mysize.profile_image_width,
              borderWidth: 5.0,
              padding: 0,
              isNetworkImage: isProfileAvailable,
            ),
          ),
        ),

        SizedBox(height: Mysize.spaceBtwItems),
        // User Name
        Text(
          user.fullName,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: isDark ? Mycolors.light : Mycolors.dark,
          ),
        ),
        SizedBox(height: Mysize.spaceBtwItems),

        // User phone Number
        Text(user.phoneNumber, style: Theme.of(context).textTheme.bodyLarge),

        SizedBox(height: Mysize.spaceBtwItems),

        // User about
        Text(
          user.about,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
