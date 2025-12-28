import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/phone_number_change/second_screen.dart';
import 'package:whats_app/utiles/theme/const/text.dart';

class ChangeNumberFirstScreen extends StatelessWidget {
  const ChangeNumberFirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B141A),
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
                    color: Colors.white54,
                    fontSize: 24,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(width: 12),
                _simIcon(Color(0xFFDFFFD6)),
              ],
            ),

            SizedBox(height: 32),

            /// MAIN TEXT
            Text(
              MyText.changeNumberMainText,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
            ),

            SizedBox(height: 20),

            /// SUB TEXT
            Text(
              MyText.changeNumberSubText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            SizedBox(height: 20),

            Text(
              MyText.changeNumberlastText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
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
