import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/feature/authentication/backend/Re-send_otp_controller/re_send_otp.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

void showCustomBottomSheet(BuildContext context) {
  bool dark = MyHelperFunction.isDarkMode(context);

  final OtpController = Get.put(ReSendOtpController());
  final controller = AuthenticationRepository.instance;
  showModalBottomSheet(
    context: context,
    backgroundColor: dark ? Mycolors.light : Mycolors.dark,
    builder: (context) {
      return Container(
        height: 150,
        width: double.infinity,

        child: Padding(
          padding: MyPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.message,
                        color: dark ? Mycolors.dark : Mycolors.light,
                      ),
                      SizedBox(width: Mysize.fontSizeLg),
                      Text(
                        MyText.verify_phone_number_resent_otp,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: dark ? Mycolors.dark : Mycolors.light,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    return TextButton(
                      onPressed:
                          OtpController.remainingsec.value == 0 &&
                              !OtpController.isResend.value
                          ? () {
                              OtpController.resendOtp(() async {
                                controller.resendOtp();
                              }, 120);
                            }
                          : null,
                      child: OtpController.isResend.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              OtpController.remainingsec.value == 0
                                  ? MyText.verify_phone_number_resent_text
                                  : "Resend in ${OtpController.remainingsec.value}s",
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Mycolors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
