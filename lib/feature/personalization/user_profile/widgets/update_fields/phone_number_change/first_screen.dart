import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/personalization/user_profile/widgets/update_fields/phone_number_change/second_screen.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChangeNumberFirstScreen extends StatelessWidget {
  const ChangeNumberFirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: MyAppbar(
        showBackArrow: true,
        title: Text(
          "Change Number",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: MyElevatedButton(
        onPressed: () => Get.to(ChangeNumberSecondScreen()),
        text: "Change",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          children: [
            SizedBox(height: 40),

            /// SIM ICON ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _simIcon(Color(0xFF25D366)),
                SizedBox(width: 12),
                Text(
                  "• • •",
                  style: TextStyle(
                    color: isDark ? Mycolors.light : Mycolors.dark,
                    fontSize: 24,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(width: 12),
                _simIcon(Color.fromARGB(255, 140, 231, 115)),
              ],
            ),

            SizedBox(height: 32),

            /// MAIN TEXT
            Text(
              MyText.changeNumberMainText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Mycolors.light : Mycolors.dark,
                fontSize: 16,
                height: 1.4,
              ),
            ),

            SizedBox(height: 20),

            /// SUB TEXT
            Text(
              MyText.changeNumberSubText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Mycolors.light
                    : const Color.fromARGB(205, 39, 39, 39),
                fontSize: 14,
                height: 1.4,
              ),
            ),

            SizedBox(height: 20),

            Text(
              MyText.changeNumberlastText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Mycolors.light : Mycolors.dark,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SIM ICON WIDGET
  Widget _simIcon(Color color) {
    return Transform.rotate(
      angle: math.pi / 2,
      child: Icon(Icons.sim_card, size: 90, color: color),
    );
  }
}
