import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChangeNumberOtpScreen extends StatelessWidget {
  const ChangeNumberOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunction.isDarkMode(context);
    final isDark = MyHelperFunction.isDarkMode(context);
    // verify code input box theme
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 60,
      textStyle: TextStyle(
        fontSize: Mysize.fontSizeLg,
        fontWeight: FontWeight.bold,
        color: dark ? Mycolors.light : Colors.black,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: dark ? Mycolors.light.withOpacity(0.5) : Mycolors.grey,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFF0B141A),
      appBar: MyAppbar(
        title: Text(
          "Verify Number",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
      ),
      floatingActionButton: MyElevatedButton(onPressed: () {}, text: "Verify"),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: Mysize.defaultSpace * 3),

            Center(
              child: Text(
                textAlign: TextAlign.center,
                MyText.changeNumberOtpScreenText,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: isDark ? Mycolors.light : Mycolors.dark,
                ),
              ),
            ),
            SizedBox(height: Mysize.spaceBtwInputFields * 2),
            // verify code input box
            Center(
              child: Pinput(
                // key: controller.otpKey,
                length: 6,
                // controller: controller.otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    border: Border.all(color: Mycolors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onCompleted: (pin) {
                  debugPrint('Entered OTP: $pin');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
