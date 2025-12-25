import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/bottom_sheet.dart';
import 'package:whats_app/utiles/theme/const/image.dart';

class OnScreenProfile extends StatelessWidget {
  const OnScreenProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

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
          IconButton(
            onPressed: () => showEditProfileBottomSheet(context),
            icon: Icon(Iconsax.edit),
          ),
          IconButton(onPressed: () {}, icon: Icon(Iconsax.share)),
        ],
      ),
      body: Center(
        child: Obx(() {
          final user = controller.user.value;

          return Hero(
            tag: 'profile-photo',
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 10),
              child: user.profilePicture.isNotEmpty
                  ? CachedNetworkImage(
                      key: ValueKey(user.profilePicture),
                      height: 425,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: user.profilePicture,
                      placeholder: (_, __) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (c, url, err) =>
                          CircleAvatar(child: Icon(Iconsax.user)),
                    )
                  : Image.asset(
                      MyImage.onProfileScreen,
                      key: ValueKey('default'),
                      fit: BoxFit.cover,
                    ),
            ),
          );
        }),
      ),
    );
  }
}
