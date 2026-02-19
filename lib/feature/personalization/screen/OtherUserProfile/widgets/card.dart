import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/CustomCard/MyCustomCard.dart';
import 'package:whats_app/common/widget/ZegoCallBtn/ZegoCallBtn.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

class OtherUserCard extends StatelessWidget {
  const OtherUserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel user = Get.arguments as UserModel;

    return Row(
      children: [
        // MESSAGE
        Expanded(
          child: MyCustomCard(
            user: user,
            onTap: () => Get.to(() => ChattingScreen(), arguments: user),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 5),
                Icon(Iconsax.message, color: Mycolors.success),
                SizedBox(height: Mysize.sm),
                Text("Message", textAlign: TextAlign.center),
              ],
            ),
          ),
        ),

        SizedBox(width: Mysize.sm),

        // AUDIO CALL
        Expanded(
          child: MyCustomCard(
            user: user,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZegoCallInvitationButton(
                  otherUser: user,
                  isVideo: false,
                  icon: Iconsax.call,
                  color: Mycolors.success,
                  text: "audio",
                ),
                Text("Audio call", textAlign: TextAlign.center),
              ],
            ),
          ),
        ),

        SizedBox(width: Mysize.sm),

        // VIDEO CALL
        Expanded(
          child: MyCustomCard(
            user: user,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZegoCallInvitationButton(
                  otherUser: user,
                  isVideo: true,
                  icon: Iconsax.video,
                  color: Mycolors.success,
                  text: 'video',
                ),
                Text("Video call", textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
