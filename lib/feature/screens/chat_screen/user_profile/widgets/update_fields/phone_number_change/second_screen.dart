import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/personalization/controller/update_user_details/update_user_details_controller.dart';
import 'package:whats_app/feature/screens/chat_screen/user_profile/widgets/update_fields/phone_number_change/otp_screen.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/validation/Validations.dart';

class ChangeNumberSecondScreen extends StatelessWidget {
  const ChangeNumberSecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final updateController = Get.put(UpdateUserDetailsController());
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      appBar: MyAppbar(
        title: Text(
          "Change Number",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
      ),
      floatingActionButton: MyElevatedButton(
        onPressed: () => Get.to(ChangeNumberOtpScreen()),
        text: "Next",
      ),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          children: [
            Form(
              key: updateController.upDateUserNumberFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter your old number :",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: Mysize.md),
                  TextFormField(
                    controller: updateController.phoneNumberFirst,
                    validator: (value) =>
                        MyValidator.validateEmptyText("Phone number", value),
                    decoration: InputDecoration(
                      labelText: "Old Number",
                      prefixIcon: Icon(Iconsax.call),
                    ),
                  ),
                  SizedBox(height: Mysize.defaultSpace),
                  Text(
                    "Enter your new number with country code :",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: Mysize.md),
                  IntlPhoneField(
                    controller: updateController.phoneNumberSecond,
                    validator: (value) => MyValidator.validatePhoneNumber(
                      value?.completeNumber ?? '',
                    ),
                    decoration: const InputDecoration(
                      labelText: "New Number",
                      border: OutlineInputBorder(),
                    ),
                    initialCountryCode: 'BD',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    invalidNumberMessage: 'Enter a valid phone number',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
