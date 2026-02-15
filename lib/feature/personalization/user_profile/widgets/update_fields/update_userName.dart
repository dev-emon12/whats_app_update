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
import 'package:whats_app/utiles/validation/Validations.dart';

class UpdateUserName extends StatelessWidget {
  UpdateUserName({super.key});

  final controller = UserController.instance;

  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);
    final updateController = Get.put(UpdateUserDetailsController());

    return Scaffold(
      appBar: MyAppbar(
        showBackArrow: true,
        title: Text("Name", style: Theme.of(context).textTheme.headlineMedium),
      ),

      floatingActionButton: MyElevatedButton(
        onPressed: () => updateController.updateUserName(),
        text: "Save",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          children: [
            Form(
              key: updateController.upDateUserNameFormKey,
              child: TextFormField(
                controller: updateController.username,
                validator: (value) =>
                    MyValidator.validateEmptyText("Name", value),
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
            ),
            SizedBox(height: Mysize.defaultSpace),
            Text(
              MyText.editNameAbout,
              style: TextStyle(color: isDark ? Mycolors.light : Mycolors.dark),
            ),
          ],
        ),
      ),
    );
  }
}
