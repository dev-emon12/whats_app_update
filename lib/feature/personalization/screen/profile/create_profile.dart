import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/authentication/screens/log_in_screen/widget/UserProfileWithUserIcon.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/validation/Validations.dart';

class profile_screen extends StatelessWidget {
  const profile_screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    return Scaffold(
      floatingActionButton: MyElevatedButton(
        onPressed: () {
          final username = controller.userName.text.trim();
          final photo =
              UserController.instance.user.value.profilePicture.isEmpty;
          if (username.isEmpty && photo) {
            Get.snackbar(
              'Invalid',
              "Profile picture and Username can't be empty",
              snackPosition: SnackPosition.TOP,
            );
            return;
          }
          controller.saveUserRecord();
        },
        text: "Next",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Center(
        child: Padding(
          padding: MyPadding.screenPadding,
          child: Padding(
            padding: const EdgeInsets.only(top: 20 * 2),
            child: Column(
              children: [
                // profile picture
                Text(
                  MyText.profile_picture,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                SizedBox(height: Mysize.spaceBtwSections),

                // Profile picture
                UserProfileWithUserIcon(),

                SizedBox(height: Mysize.spaceBtwSections * 2),

                // Name_filed
                TextFormField(
                  validator: (value) => MyValidator.validateEmptyText(
                    "UserName can't be empty",
                    value,
                  ),
                  controller: controller.userName,
                  decoration: InputDecoration(
                    hintText: "Enter your name...",
                    suffixIcon: Icon(Iconsax.emoji_happy),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
