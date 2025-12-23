import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/feature/authentication/screens/verify_screen/widgets/Re-send_otp.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class verify_screen extends StatelessWidget {
  const verify_screen({super.key});

  @override
  Widget build(BuildContext context) {
    bool dark = MyHelperFunction.isDarkMode(context);
    AuthenticationRepository controller = Get.put(AuthenticationRepository());

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
      floatingActionButton: MyElevatedButton(
        onPressed: () {
          final otp = controller.otpController.text.trim();

          if (otp.isEmpty) {
            Get.snackbar(
              'Invalid OTP',
              "OTP can't be empty",
              snackPosition: SnackPosition.TOP,
            );
            return;
          }
          controller.verifyWithOtp();
        },
        text: "Verify",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      appBar: MyAppbar(showBackArrow: true),
      body: Center(
        child: Padding(
          padding: MyPadding.screenPadding,
          child: Padding(
            padding: const EdgeInsets.only(top: 20 * 2),
            child: Column(
              children: [
                Text(
                  MyText.verify_phone_number_1st_text,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                SizedBox(height: Mysize.spaceBtwItems),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: dark ? Mycolors.light : Colors.black,
                      height: 1.8,
                    ),
                    children: [
                      TextSpan(text: MyText.verify_phone_number_2nd_text),
                      TextSpan(text: MyText.verify_phone_number_3rd_text),
                      TextSpan(
                        text: controller.fullPhone.string,
                        style: TextStyle(
                          fontSize: Mysize.fontSizeMd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: MyText.verify_phone_number_4rt_text,
                        style: TextStyle(color: Mycolors.primary),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Mysize.spaceBtwSections),

                // verify code input box
                Pinput(
                  key: controller.otpKey,
                  length: 6,
                  controller: controller.otpController,

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

                SizedBox(height: Mysize.searchBarHeight),

                // didn't receive code
                GestureDetector(
                  onTap: () {
                    showCustomBottomSheet(context);
                  },
                  child: Text(
                    MyText.verify_screen_receive_code,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: Mycolors.success),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
