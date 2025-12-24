import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/theme/const/image.dart';

class OnScreenProfile extends StatelessWidget {
  const OnScreenProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Get.arguments as UserModel?;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Something Went Wrong")));
    }
    return Scaffold(
      appBar: MyAppbar(
        title: Text(
          "Profile photo",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Iconsax.edit)),
          IconButton(onPressed: () {}, icon: Icon(Iconsax.share)),
        ],
      ),
      body: Center(
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(100),
          child: user.profilePicture.isNotEmpty
              ? CachedNetworkImage(
                  height: 425,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: user.profilePicture,
                  errorWidget: (c, url, err) =>
                      CircleAvatar(child: Icon(Iconsax.user)),
                )
              : Image.asset(MyImage.onProfileScreen, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
