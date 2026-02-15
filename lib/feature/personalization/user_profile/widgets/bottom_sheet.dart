import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/custom_bottom_sheet_button/custom_btn_icon_bottom_sheet.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

void showEditProfileBottomSheet(BuildContext context) {
  final Usercontroller = Get.put(UserController());
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        topLeft: Radius.circular(20),
      ),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile Photo",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: Mysize.iconMd,
                      color: Mycolors.error,
                    ),
                  ),
                ],
              ),
            ),

            // Options
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  optionItem(
                    icon: Icons.camera_alt_outlined,
                    name: "Camera",
                    onTap: () => UserController.instance
                        .updateUserProfilePictureFromCamera(),
                  ),
                  optionItem(
                    icon: Iconsax.gallery,
                    name: "Gallery",
                    onTap: () => UserController.instance
                        .updateUserProfilePictureFromGallery(),
                  ),
                  optionItem(icon: Icons.face, name: "Avatar", onTap: () {}),
                  optionItem(
                    icon: Icons.facebook_outlined,
                    name: "Facebook",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
