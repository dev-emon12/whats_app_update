import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/ZegoCallBtn/ZegoCallBtn.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/circular_image/MyCircularImage.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

class OtherUserProfile extends StatelessWidget {
  const OtherUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel user = Get.arguments as UserModel;

    final pic = user.profilePicture.toString();

    bool isProfileAvailable = pic.isNotEmpty;

    return Scaffold(
      backgroundColor: Color(0xFF0B141A),
      appBar: MyAppbar(showBackArrow: true),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          children: [
            // User Image
            Center(
              child: MyCirculerImage(
                image: isProfileAvailable ? pic : MyImage.onProfileScreen,
                height: Mysize.profile_image_height,
                width: Mysize.profile_image_width,
                borderWidth: 5.0,
                padding: 0,
                isNetworkImage: isProfileAvailable,
              ),
            ),
            SizedBox(height: Mysize.spaceBtwItems),
            // User Name
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: Mysize.spaceBtwItems),

            // User phone Number
            Text(
              user.phoneNumber,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: Mysize.spaceBtwItems),

            // User about
            Text(
              user.about,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
            ),
            SizedBox(height: Mysize.spaceBtwSections * 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // message card
                GestureDetector(
                  onTap: () => Get.to(ChattingScreen(), arguments: user),
                  child: Container(
                    height: 75,
                    width: 100,
                    decoration: BoxDecoration(
                      // color: Color.fromARGB(53, 196, 196, 196),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(200, 98, 109, 119),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.message,
                            color: const Color.fromARGB(255, 58, 195, 65),
                          ),
                          SizedBox(height: Mysize.sm),
                          Text("Message"),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Mysize.md),

                // audio call card
                Container(
                  height: 75,
                  width: 100,
                  decoration: BoxDecoration(
                    // color: Color.fromARGB(53, 196, 196, 196),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(200, 98, 109, 119),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        ZegoCallInvitationButton(
                          otherUser: user,
                          isVideo: false,
                          icon: Iconsax.call,
                          color: const Color.fromARGB(255, 58, 195, 65),
                          text: "audio",
                        ),
                        Text("Audio call"),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: Mysize.md),

                // video call card
                Container(
                  height: 75,
                  width: 100,
                  decoration: BoxDecoration(
                    // color: Color.fromARGB(53, 196, 196, 196),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(200, 98, 109, 119),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        ZegoCallInvitationButton(
                          otherUser: user,
                          isVideo: true,
                          icon: Iconsax.video,
                          color: const Color.fromARGB(255, 58, 195, 65),
                          text: 'video',
                        ),
                        Text("Video call"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
