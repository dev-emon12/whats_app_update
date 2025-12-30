import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/Profile_screen_widgets/Custom_profile_screen_widget.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/feature/authentication/screens/log_in_screen/widget/UserProfileLogo.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/bottom_sheet.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/show_profile_in_big_screen.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/delete_user/re_authenticate.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/phone_number_change/first_screen.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/update_about.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/update_email.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/update_userName.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';

class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  final controller = UserController.instance;
  final authRepo = AuthenticationRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B141A),

      appBar: MyAppbar(
        title: Text(
          MyText.profile,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
        actions: [
          IconButton(
            onPressed: () => authRepo.logoutUser(),
            icon: Icon(Iconsax.logout, color: Colors.red),
          ),
        ],
      ),

      body: Padding(
        padding: MyPadding.screenPadding,
        child: Obx(() {
          final user = controller.user.value;

          if (user.id.isEmpty) {
            return Center(child: CircularProgressIndicator(strokeWidth: .3));
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    final user = controller.user.value;
                    Get.to(() => OnScreenProfile(), arguments: user);
                  },
                  child: UserProfileLogo(),
                ),
              ),
              SizedBox(height: Mysize.sm),

              TextButton(
                onPressed: () {
                  showEditProfileBottomSheet(context);
                },
                child: Text(
                  "Edit",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Mycolors.buttonPrimary,
                  ),
                ),
              ),

              SizedBox(height: Mysize.xl),

              User_Details_widget(
                fieldname: "Name",
                icon: Iconsax.user,
                userDetails: () => UserController.instance.user.value.username,
                onTap: () => Get.to(() => UpdateUserName()),
              ),
              SizedBox(height: Mysize.lg),

              User_Details_widget(
                fieldname: "About",
                icon: Icons.error_outline,
                userDetails: () => UserController.instance.user.value.about,
                onTap: () => Get.to(() => UpdateUserAbout()),
              ),
              SizedBox(height: Mysize.lg),

              User_Details_widget(
                fieldname: "Phone",
                icon: Iconsax.call,
                userDetails: () =>
                    UserController.instance.user.value.phoneNumber,
                onTap: () => Get.to(ChangeNumberFirstScreen()),
              ),
              SizedBox(height: Mysize.lg),

              User_Details_widget(
                fieldname: "E-mail",
                icon: Icons.mail_outline,
                userDetails: () => UserController.instance.user.value.email,
                onTap: () => Get.to(UpDateUserEmail()),
              ),
              SizedBox(height: Mysize.xl),

              TextButton(
                onPressed: () => Get.to(ReAuthenticate()),
                child: Text(
                  "Close account",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: Mycolors.error),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
