import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/search_bar/search_bar.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/authentication/backend/chatScreenController/ChatScreenController.dart';
import 'package:whats_app/feature/screens/chat_screen/widgets/chat_list.dart';
import 'package:whats_app/feature/screens/chat_screen/widgets/popUpMenu.dart';
import 'package:whats_app/utiles/CameraAccess/CameraAccess.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class chat_screen extends StatelessWidget {
  const chat_screen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatScreenController());
    final RepoController = Get.put(UserRepository());
    final controller = Get.put(CameraAccess());
    bool isDark = MyHelperFunction.isDarkMode(context);

    return Scaffold(
      // AppBar
      appBar: MyAppbar(
        title: Text(
          MyText.WhatsApp,
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            color: isDark ? Mycolors.borderPrimary : Mycolors.textPrimary,
          ),
        ),
        actions: [
          // Camera Icon
          IconButton(
            onPressed: controller.GetCameraAccess,
            icon: const Icon(Icons.camera_alt),
          ),

          //3 DOTS MENU
          popUpMenu(),
        ],
      ),

      // add button
      floatingActionButton: SizedBox(
        height: Mysize.floatingButtonHeight,
        width: Mysize.anotherfloatingButtonWidth,
        child: ElevatedButton(
          onPressed: () async {
            // await NotificationService.instance.showChatNotification(
            //   id: 1,
            //   title: "Test",
            //   body: "Hello",
            //   payload: "test_payload",
            // );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: const Color.fromARGB(255, 2, 173, 65),
            side: BorderSide.none,
          ),
          child: Icon(
            Icons.add,
            size: Mysize.iconLg,
            color: isDark ? Mycolors.textPrimary : Mycolors.light,
          ),
        ),
      ),

      body: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 15,
              top: 20,
            ),
            child: chat_screen_search_bar(),
          ),

          // SizedBox(height: Mysize.spaceBtwSections),

          // chats
          chat_screen_chat_list(),
        ],
      ),
    );
  }
}
