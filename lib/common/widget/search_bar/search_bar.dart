import 'package:flutter/material.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChatScreenSearchBar extends StatelessWidget {
  const ChatScreenSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? Mycolors.borderPrimary : Mycolors.textPrimary,
        ),
        hintText: "Ask Meta AI or Search",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}
