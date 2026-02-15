import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/personalization/controller/update_user_details/update_user_details_controller.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';
import 'package:whats_app/utiles/validation/Validations.dart';

class UpDateUserEmail extends StatelessWidget {
  const UpDateUserEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);
    final updateController = Get.put(UpdateUserDetailsController());
    return Scaffold(
      appBar: MyAppbar(
        showBackArrow: true,
        title: Text(
          "E-mail",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),

      floatingActionButton: MyElevatedButton(
        onPressed: () => updateController.updateUserEmail(),
        text: "Save",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: updateController.upDateUserEmailFormKey,
              child: TextFormField(
                controller: updateController.emailController,
                validator: (value) => MyValidator.validateEmail(value),
                decoration: InputDecoration(
                  labelText: "E-mail",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            SizedBox(height: Mysize.defaultSpace),
            Text(
              MyText.editUserEmail,
              textAlign: TextAlign.start,
              style: TextStyle(color: isDark ? Mycolors.light : Mycolors.dark),
            ),
          ],
        ),
      ),
    );
  }
}
