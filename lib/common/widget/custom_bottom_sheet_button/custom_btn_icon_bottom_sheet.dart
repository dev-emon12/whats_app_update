import 'package:flutter/material.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class optionItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback onTap;

  const optionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 40),
        child: Padding(
          padding: EdgeInsets.only(left: 30),
          child: Row(
            children: [
              Icon(icon, size: 25),
              SizedBox(height: Mysize.defaultSpace),
              Flexible(
                child: Text(
                  "   $name",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Mycolors.light : Mycolors.dark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
