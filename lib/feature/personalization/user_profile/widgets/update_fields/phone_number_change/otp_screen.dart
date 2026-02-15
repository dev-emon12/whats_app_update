import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/feature/authentication/backend/Re-send_otp_controller/re_send_otp.dart';
import 'package:whats_app/feature/personalization/controller/update_user_details/update_user_details_controller.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChangeNumberOtpScreen extends StatelessWidget {
  final String verificationId;

  const ChangeNumberOtpScreen({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunction.isDarkMode(context);

    final resendOtpController = Get.put(ReSendOtpController());
    final controller = Get.put(UpdateUserDetailsController());

    if (controller.verifyId.isEmpty) {
      controller.verifyId = verificationId;
    }

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
      backgroundColor: const Color(0xFF0B141A),
      appBar: MyAppbar(
        title: const Text("Verify Number"),
        showBackArrow: true,
        actions: [
          Obx(() {
            return TextButton(
              onPressed:
                  resendOtpController.remainingsec.value == 0 &&
                      !resendOtpController.isResend.value
                  ? () {
                      resendOtpController.resendOtp(
                        () => AuthenticationRepository.instance.resendOtp(),
                        120,
                      );
                    }
                  : null,
              child: resendOtpController.isResend.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      resendOtpController.remainingsec.value == 0
                          ? MyText.verify_phone_number_resent_text
                          : "Resend in ${resendOtpController.remainingsec.value}s",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Mycolors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          }),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MyElevatedButton(
        onPressed: controller.confirmNewNumberOtp,
        text: "Verify",
      ),

      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          children: [
            SizedBox(height: Mysize.defaultSpace * 3),
            Text(
              MyText.changeNumberOtpScreenText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: dark ? Mycolors.light : Mycolors.dark,
              ),
            ),
            SizedBox(height: Mysize.spaceBtwInputFields * 2),

            Form(
              key: controller.upDateUserOtpFormKey,
              child: Pinput(
                length: 6,
                controller: controller.otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    border: Border.all(color: Mycolors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().length != 6) {
                    return "Enter 6 digit OTP";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
