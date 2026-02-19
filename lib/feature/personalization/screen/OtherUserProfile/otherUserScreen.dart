import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/widgets/Images.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/widgets/UserDetails.dart';
import 'package:whats_app/feature/personalization/screen/OtherUserProfile/widgets/card.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';

class OtherUserProfile extends StatelessWidget {
  const OtherUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel otherUser = Get.arguments as UserModel;

    return Scaffold(
      // backgroundColor: Color(0xFF0B141A),
      appBar: MyAppbar(showBackArrow: true),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          children: [
            // User details
            UserDetails(),

            SizedBox(height: Mysize.spaceBtwSections * 1),
            // Messsage and call's card
            OtherUserCard(),

            SizedBox(height: Mysize.spaceBtwSections),

            // Images text
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                MyText.imgText,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontSize: 18),
              ),
            ),
            SizedBox(height: Mysize.iconSm),

            // show all chat images
            ChatImages(otherUserId: otherUser.id),
          ],
        ),
      ),
    );
  }
}
