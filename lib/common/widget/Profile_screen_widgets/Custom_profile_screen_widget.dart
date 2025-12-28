import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class User_Details_widget extends StatelessWidget {
  const User_Details_widget({
    super.key,
    required this.icon,
    required this.fieldname,
    required this.userDetails,
    required this.onTap,
  });

  final String fieldname;
  final IconData icon;
  final String Function() userDetails;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: isDark ? Mycolors.light : Mycolors.dark),
          SizedBox(width: Mysize.xl),

          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fieldname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: isDark ? Mycolors.light : Mycolors.dark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userDetails(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: isDark ? Mycolors.light : Mycolors.dark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
