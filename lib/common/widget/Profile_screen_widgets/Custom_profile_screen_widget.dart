import 'package:flutter/material.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class User_Details_widget extends StatelessWidget {
  const User_Details_widget({
    super.key,
    required this.icon,
    required this.userDetails,
    required this.fieldname,
    required this.onTap,
  });

  final String fieldname;
  final IconData icon;
  final String userDetails;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: isDark ? Mycolors.light : Mycolors.dark),
          SizedBox(width: Mysize.xl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldname,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: isDark ? Mycolors.light : Mycolors.dark,
                ),
              ),
              SizedBox(height: 5),
              Text(
                userDetails,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isDark ? Mycolors.light : Mycolors.dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
