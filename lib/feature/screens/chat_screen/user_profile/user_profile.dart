import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/Profile_screen_widgets/Custom_profile_screen_widget.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/common/widget/Profile_screen_widgets/Custom_profile_widget.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';

class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Get.arguments as UserModel?;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("No user provided")));
    }
    return Scaffold(
      appBar: MyAppbar(
        title: Text(
          MyText.profile,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // profile widget
            Center(child: Custom_profile_widget(user: user)),
            SizedBox(height: Mysize.sm),

            // edit button
            TextButton(
              onPressed: () {},
              child: Text(
                "Edit",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Mycolors.buttonPrimary,
                ),
              ),
            ),

            SizedBox(height: Mysize.xl),

            // User Details Name Filed
            User_Details_widget(
              fieldname: "Name",
              icon: Iconsax.user,
              userDetails: user.username,
              onTap: () {},
            ),
            SizedBox(height: Mysize.lg),

            // User Details About Filed
            User_Details_widget(
              fieldname: "About",
              icon: Icons.error_outline,
              userDetails: user.about,
              onTap: () {},
            ),
            SizedBox(height: Mysize.lg),

            // User Details Phone Filed
            User_Details_widget(
              fieldname: "Phone",
              icon: Iconsax.call,
              userDetails: user.phoneNumber,
              onTap: () {},
            ),
            SizedBox(height: Mysize.lg),

            // User Details Links Filed
            User_Details_widget(
              fieldname: "Links",
              icon: Iconsax.link,
              userDetails: "Add Links",
              onTap: () {},
            ),
            SizedBox(height: Mysize.lg),

            // User Details E-mail Filed
            User_Details_widget(
              fieldname: "E-mail",
              icon: Icons.mail_outline,
              userDetails: user.email,
              onTap: () {},
            ),
            SizedBox(height: Mysize.xl),

            // Ac Delete button
            TextButton(
              onPressed: () {},
              child: Text(
                "Close account",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: Mycolors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
