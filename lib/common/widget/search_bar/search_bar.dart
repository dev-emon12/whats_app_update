import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/screens/chat_screen/controller/searchController.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChatScreenSearchBar extends StatelessWidget {
  const ChatScreenSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);
    final controller = Get.put(ChatSearchController());

    return TextFormField(
      controller: controller.searchController,
      onChanged: controller.onQueryChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? Mycolors.borderPrimary : Mycolors.textPrimary,
        ),
        hintText: "Search user",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}
