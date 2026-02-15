import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/personalization/controller/update_user_details/update_user_details_controller.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ReAuthenticate extends StatelessWidget {
  const ReAuthenticate({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);
    final controller = UserController.instance;
    final upDateController = Get.put(UpdateUserDetailsController());
    return Scaffold(
      appBar: MyAppbar(
        showBackArrow: true,
        title: Text(
          "Re-authenticate",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: MyElevatedButton(
        text: "Verify",
        onPressed: () => controller.sendOtpForDelete(),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          children: [
            Text(
              MyText.re_authenticAboutText,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isDark ? Mycolors.light : Mycolors.dark,
              ),
            ),

            SizedBox(height: Mysize.defaultSpace),
            TextFormField(
              readOnly: true,
              controller: upDateController.reAuthenticate,
              enabled: false,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Iconsax.call),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
