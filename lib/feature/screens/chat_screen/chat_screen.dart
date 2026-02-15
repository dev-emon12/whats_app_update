import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/search_bar/search_bar.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/authentication/backend/chat_list_controller/chatListController.dart';
import 'package:whats_app/feature/screens/add_user_screen/find_user.dart';
import 'package:whats_app/feature/personalization/user_profile/user_profile.dart';
import 'package:whats_app/feature/screens/chat_screen/widgets/chat_list.dart';
import 'package:whats_app/utiles/CameraAccess/CameraAccess.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CameraAccess());
    final chatListController = Get.put(ChatListController());
    bool isDark = MyHelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: MyAppbar(
        title: Obx(() {
          if (chatListController.isSelecting.value) {
            return TextButton(
              onPressed: chatListController.clearSelection,
              child: Text(
                "Cancel",
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium!.copyWith(color: Mycolors.error),
              ),
            );
          } else {
            return Text(
              MyText.WhatsApp,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: isDark ? Mycolors.borderPrimary : Mycolors.textPrimary,
              ),
            );
          }
        }),
        actions: [
          Obx(() {
            if (chatListController.isSelecting.value) {
              return SizedBox();
            } else {
              return IconButton(
                onPressed: controller.GetCameraAccess,
                icon: Icon(Icons.camera_alt_outlined),
              );
            }
          }),
          SizedBox(width: Mysize.sm),

          Obx(() {
            if (chatListController.isSelecting.value) {
              return IconButton(
                icon: Icon(Icons.delete),
                onPressed: chatListController.deleteChat,
              );
            } else {
              return IconButton(
                icon: Icon(Iconsax.user),
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  final user = await UserRepository.instance.getUserById(uid);
                  if (user == null) return;

                  Get.to(() => UserProfile(), arguments: user);
                },
              );
            }
          }),
        ],
      ),
      // floating action button
      floatingActionButton: SizedBox(
        height: Mysize.floatingButtonHeight,
        width: Mysize.anotherfloatingButtonWidth,
        child: ElevatedButton(
          onPressed: () => Get.to(FindUser()),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Color.fromARGB(255, 2, 173, 65),
            side: BorderSide.none,
          ),
          child: Icon(
            Icons.add,
            size: Mysize.iconMd,
            color: isDark ? Mycolors.dark : Mycolors.light,
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() {
            if (chatListController.isSelecting.value) {
              return SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.all(15),
              child: ChatScreenSearchBar(),
            );
          }),

          ChatScreenChatList(),
        ],
      ),
    );
  }
}
