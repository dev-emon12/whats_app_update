import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/show_profile_in_big_screen.dart';
import 'package:whats_app/utiles/theme/const/image.dart';

class Custom_profile_widget extends StatelessWidget {
  const Custom_profile_widget({super.key, required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        final user = await UserRepository.instance.getUserById(uid);
        Get.to(() => OnScreenProfile(), arguments: user);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1000),
        child: user!.profilePicture.isNotEmpty
            ? CachedNetworkImage(
                height: 225,
                width: 225,
                fit: BoxFit.cover,
                imageUrl: user!.profilePicture,
                errorWidget: (c, url, err) =>
                    CircleAvatar(child: Icon(Iconsax.user)),
              )
            : Image.asset(MyImage.onProfileScreen, fit: BoxFit.cover),
      ),
    );
  }
}
