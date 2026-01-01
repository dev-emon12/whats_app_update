import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:whats_app/utiles/validation/Validations.dart';

class Log_in_screen extends StatelessWidget {
  const Log_in_screen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationRepository controller = Get.put(AuthenticationRepository());
    bool dark = MyHelperFunction.isDarkMode(context);
    return Scaffold(
      floatingActionButton: Obx(() {
        final isEmpty = controller.fullPhone.value.isEmpty;

        return MyElevatedButton(
          onPressed: isEmpty
              ? null
              : () {
                  controller.signInWithPhoneNumber();
                },
          text: "Next",
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Center(
        child: Padding(
          padding: MyPadding.screenPadding,
          child: Padding(
            padding: const EdgeInsets.only(top: 20 * 2),
            child: Column(
              children: [
                Text(
                  MyText.log_in_screen_1st_text,
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
                      TextSpan(text: MyText.log_in_screen_2nd_text),
                      TextSpan(text: MyText.log_in_screen_3rd_text),
                      TextSpan(
                        text: MyText.log_in_screen_4rt_text,
                        style: TextStyle(color: Mycolors.primary),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Mysize.searchBarHeight),

                // phone number filed
                Form(
                  key: controller.signUpKey,
                  child: IntlPhoneField(
                    validator: (value) => MyValidator.validatePhoneNumber(
                      value?.completeNumber ?? '',
                    ),
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    initialCountryCode: 'BD',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    invalidNumberMessage: 'Enter a valid phone number',
                    onChanged: (phone) {
                      controller.fullPhone.value = phone.completeNumber.trim();
                    },
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
