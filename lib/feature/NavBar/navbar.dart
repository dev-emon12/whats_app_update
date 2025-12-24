import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/feature/screens/calls_screen/calls_screen.dart';
import 'package:whats_app/feature/screens/chat_screen/chat_screen.dart';
import 'package:whats_app/feature/screens/communities_screen/communities_screen.dart';
import 'package:whats_app/feature/screens/update_screen/update_screen.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class navigationMenuScreen extends StatelessWidget {
  const navigationMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool dark = MyHelperFunction.isDarkMode(context);
    final controller = Get.put(navigationController());
    return Scaffold(
      body: Obx(() => controller.Screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          backgroundColor: dark ? Mycolors.dark : Mycolors.light,
          indicatorColor: dark
              ? Color.fromARGB(255, 2, 173, 65).withValues(alpha: .2)
              : Mycolors.dark.withValues(alpha: .1),
          onDestinationSelected: (index) {
            controller.selectedIndex.value = index;
          },
          destinations: [
            NavigationDestination(icon: Icon(Iconsax.message), label: "Chats"),
            NavigationDestination(
              icon: Icon(Iconsax.message_square4),
              label: "Updates",
            ),
            NavigationDestination(
              icon: Icon(Iconsax.people),
              label: "Communities",
            ),
            NavigationDestination(icon: Icon(Iconsax.call), label: "Calls"),
          ],
        ),
      ),
    );
  }
}

class navigationController extends GetxController {
  static navigationController get instance => Get.find();

  RxInt selectedIndex = 0.obs;
  List<Widget> Screens = [
    chat_screen(),
    update_screen(),
    communities_screen(),
    call_screen(),
  ];
}
